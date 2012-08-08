#
# Lexical Scanner of Sreg Project
#
# Shou Ya, 30 July
#


require 'stringio'

module Sreg
  module Builder
    class LexerError < Exception; end

    class Lexer
      attr_reader :string
      attr_reader :state
      attr_reader :options
      attr_reader :scanner_options

      attr :stream

      ESCAPE_SEQENCES = {
        'n' => "\n",
        't' => "\t",
        'r' => "\r",
        'a' => "\a",
        'e' => "\e",
      }

      SPEC_CHAR_CLASSES = %w/w s d v h/
      SPEC_CHAR_CLASSES_INV = SPEC_CHAR_CLASSES.map(&:upcase)

      def initialize(scanner_options = {})
        reset
        @scanner_options.merge(scanner_options)
      end

      def set_input_string(string, regexp_options = {})
        reset
        @string = string
        @stream = StringIO.new(string)
        @options.merge(regexp_options)
      end


      def error(msg)

        if @scanner_options[:debug] == true
          puts
          puts @string
          print '-' * (@stream.pos - 1)
          print '^'
          print '-' * (@stream.length - @stream.pos)
          puts ''
        end

        raise LexerError, msg
      end

      def tokens
        toks = []
        begin
          toks << next_token
        end until toks.last == [false, false]
        toks
      end

      def next_token
        char = @stream.getc

        case char
        when nil
          if @state[:in_group] != 0
            error 'Group stack is not terminated.'
          else
            return [false, false] # EOF
          end

        # This and the '$' below is a temporary solution, as I have to
        #+consider those expressions in this form: `/^12|^34/`
        #+Though it is now unavailable as yet alternation is not supported.
        when '^'
          if @stream.pos == 1 # 0 + '^'.length
            return ['^', nil]
          else
            return [:CHAR, '^']
          end

        when '$'
          if @stream.eof?
            return ['$', nil]
          else
            return [:CHAR, '$']
          end
        # TODO: Give a better solution for these above after alternation
        #+is supported.

        when '.'
          if @state[:in_char_class]
            return [:CHAR, '.']
          else
            return ['.', nil]
          end

        when '('
          if @state[:in_char_class]
            return [:CHAR, '(']
          else
            @state[:in_group] += 1
            if peek_char == '?'
              @stream.getc
              case @stream.getc
              when '#'
                error 'Endless comment.' unless eat_until(')')
                @state[:in_group] -= 1
                return next_token
              else
                error 'Unrecognized extension.'
              end
            else
              return ['(', nil]
            end
          end

        when ')'
          if @state[:in_char_class]
            return [:CHAR, ')']
          else
            if @state[:in_group] > 0
              @state[:in_group] -= 1
              return [')', nil]
            else
              return [:CHAR, ')']
            end
          end

        when '['
          if @state[:in_char_class]
            if peek_char == ':'
              @stream.getc
              pclass_name = get_letters
              if @stream.getc == ':'
                if @stream.getc == ']'
                  return [:POSIX_CHAR_CLASS, pclass_name]
                end
              end
              error 'Invalid syntax for POSIX char class.'
            else
              return [:CHAR, '[']
            end
          else
            @state[:in_char_class] = true
            if peek_char == '^'
              @stream.getc
              return ['[^', nil]
            else
              return ['[', nil]
            end
          end

        when ']'
          if @state[:in_char_class]
            @state[:in_char_class] = false
            return [']', nil]
          else
            return [:CHAR, ']']
          end

        when '-'
          if @state[:in_char_class]
            return ['-', nil]
          else
            return [:CHAR, '-']
          end

        when '*'
          return [:CHAR, '*'] if @state[:in_char_class]
          return ['*', nil]
        when '+'
          return [:CHAR, '+'] if @state[:in_char_class]
          return ['+', nil]
        when '?'
          return [:CHAR, '?'] if @state[:in_char_class]
          return ['?', nil]

        when '{'
          return [:CHAR, '{'] if @state[:in_char_class]

          if @state[:in_repetition_spec]
            error 'Can\'t have special characters in repetition specification.'
          else
            @state[:in_repetition_spec] = true
            return parse_repetition
          end

        when '}'
          return [:CHAR, '}']

        when '\\'
          return parse_escape

        when '^', '$'
          return [char, nil]

        else
          return [:CHAR, char]
        end
      end

      private
      def reset
        @string = ''
        @stream = nil
        @state = {
          :in_group => 0,
          :in_char_class => false,
          :in_repetition_spec => false,
        }
        @options = {}
        @scanner_options = {}
      end

      def parse_repetition
        unless @state[:in_repetition_spec]
          error 'Invalid calling `parse_repetition`.'
        end

        min = (peek_char == ',' ? -1 : get_integer)

        next_char = @stream.getc
        if next_char != ','
          if next_char == '}' # Fixed time repetition
            if min != -1
              return [:VAR_REPETITION, [min, min]]
            else
              error 'Invalid repetition specification.'
            end
          else
            @stream.ungetc(next_char)
            error 'Invalid repetition specification.'
          end
        end

        max = peek_char == '}' ? -1 : get_integer

        if @stream.getc != '}'
          error 'Invalid repetition specification.'
        end

        @state[:in_repetition_spec] = false


        if max == -1 and min == -1
          error 'Invalid repetition specification.'
        elsif max != -1 and min == -1
          return [:VAR_REPETITION, [0, max]]
        elsif max == -1 and min != -1
          return [:VAR_REPETITION, [min, -1]]
        elsif min <= max
          return [:VAR_REPETITION, [min, max]]
        else
          error 'Repetition specification min > max.'
        end

      end


      def parse_escape
        escaped_char = @stream.getc
        error 'Undesignated escaped charater.' unless escaped_char

        case escaped_char
        when *ESCAPE_SEQENCES.keys
          return [:CHAR, ESCAPE_SEQENCES[escaped_char]]


        when '0'
          return [:CHAR, "\0"] unless ('0'..'9').include?(peek_char)
          return [:CHAR, get_octal.chr]

        when 'x', 'X'
          if peek_char == '{'
            @stream.getc
            hex = get_hex
            error 'invalid quoted hex char' if peek_char != '}'
            @stream.getc
            return [:CHAR, hex.chr]
          else
            return [:CHAR, get_hex.chr]
          end


        when *SPEC_CHAR_CLASSES
          return [:SPEC_CHAR_CLASS, escaped_char]
        when *SPEC_CHAR_CLASSES_INV
          return [:SPEC_CHAR_CLASS_INV, escaped_char]

        when '1'..'9'
          @stream.ungetc(escaped_char)
          return [:BACK_REFERENCE, get_integer]

        else
          return [:CHAR, escaped_char]

        end
      end

      def get_integer(digit_range = '0'..'9', base = 10)
        number_str = get_chars(digit_range)
        error 'Invalid character.' if number_str.empty?
        return number_str.to_i(base)
      end

      def get_octal
        get_integer('0'..'7', 8)
      end
      def get_hex
        get_integer(('0'..'9').to_a + ('a'..'f').to_a + ('A'..'F').to_a, 16)
      end

      def get_letters
        get_chars(('a'..'z').to_a + ('A'..'Z').to_a)
      end

      def get_chars(char_range)
        result_str = ''
        char = nil

        loop do
          char = @stream.getc
          if char_range.include? char
            result_str << char
          else
            break
          end
        end

        @stream.ungetc(char)

        result_str
      end

      def peek_char
        @stream.ungetc(tmp = @stream.getc)
        return tmp
      end

      # Eat until specific character, respect escaping.
      # returns the length it eats, or nil if EOS reaches.
      def eat_until(char)
        length = 0

        loop do
          c = @stream.getc

          return nil if c.nil?

          if c == '\\'
            @stream.getc
            length += 1
            next
          end

          length += 1

          break if c == char
        end
        return length
      end

    end
  end
end
