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

      def initialize()
        reset
      end

      def set_input_string(string, regexp_options = {}, scanner_options = {})
        reset
        @string = string
        @stream = StringIO.new(string)
        @options = regexp_options
        @scanner_options = scanner_options
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
          return [false, false] # EOF

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
            return ['(', nil]
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
            return [:CHAR, '[']
          else
            @state[:in_char_class] = true
            return ['[', nil]
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
          escaped_char = @stream.getc
          if escaped_char
            return [:CHAR, escaped_char]
          else
            error 'Undesignated escaped charater.'
          end

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
        
        min = get_integer
        min = -1 if min.nil?  # Zero maybe
        
        if @stream.getc != ','
          next_char = @stream.getc
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
        
        max = get_integer
        max = -1 if max.nil? # Infinity
        
        
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
      
      def get_integer
        number_str = ''
        digit = ''
        
        loop do
          digit = @stream.getc
          if ('0'..'9').include? digit
            number_str << digit unless (number_str.empty? and digit == 0)
          else
            break
          end
        end
        
        @stream.ungetc(digit) unless digit.nil?
        
        return nil if number_str.empty?
        return number_str.to_i
      end
      
    end
  end
end
