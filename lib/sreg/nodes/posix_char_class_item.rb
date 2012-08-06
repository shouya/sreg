#
# Special character classes of Sreg project
#
# This is for those like: \d, \w and such on
#
# Shou, 6 August 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree

      class POSIXCharacterClassItem
        attr_reader :name
        def initialize(name)
          name = name.intern
          unless accepted_names.include? name
            raise(Sreg::SyntaxError,
                  "Not recognizable name #{name} in POSIX char class.")
          end

          @name = name
        end
        def to_s
          "[:#{name}:]"
        end

        def match?(char)
          case @name
          when :alnum
            [?0..?9, ?a..?z, ?A..?Z].any? {|x| x.include? char }
          when :alpha
            [?a..?z, ?A..?Z].any? {|x| x.include? char }
          when :ascii
            char.ord <= 127 and char.ord >= 0
          when :digit
            (?0..?9).include? char
          when :lower
            (?a..?z).include? char
          when :space
            SpecialCharacterClassMethods::S_CHARS.include? char
          when :upper
            (?A..?Z).include? char
          when :word
            [?0..?9, ?a..?z, ?A..?Z].any? {|x| x.include? char } or char == '_'
          when :xdigit
            [?0..?9, ?a..?f, ?A..?F].any? {|x| x.include? char }
          else
            warn "Unknown POSIX char class name #{name}."
            false
          end
        end

        def accepted_names
          [:alnum, :alpha, :ascii, :digit,
           :lower, :space, :upper, :word, :xdigit]
        end
        def as_json
          {
            :posix => name
          }
        end
      end



    end
  end
end

