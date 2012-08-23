#
# Special character classes of Sreg project
#
# This is for those like: \d, \w and such on
#
# Shou, 6 August 2012
#


class Sreg
  module Builder
    module AbstractSyntaxTree

      module SpecialCharacterClassMethods
        attr_reader :name
        def initialize(name)
          super()

          unless accepted_names.include? name
            raise(Sreg::SyntaxError,
                  "Not recognizable name #{name} in special char class.")
          end

          @name = name
        end
        def to_s
          "\\#{name}"
        end

        private

        V_CHARS = [0xa, 0xb, 0xc, 0xd, 0x85, 0x2028, 0x2029].map do |x|
          x.chr('utf-8')
        end
        H_CHARS = [0x9, 0x20, 0xa0, 0x1680, 0x180e,
                   *(0x2000..0x200a).to_a, 0x202f, 0x205f, 0x3000].map do |x|
          x.chr('utf-8')
        end

        S_CHARS = V_CHARS + H_CHARS - ['\xb']

        def match_method(char)
          case @name.downcase
          when 'd'
            ('0'..'9').include? char
          when 'w'
            ['0'..'9', 'a'..'z', 'A'..'Z', '_'..'_'].any? do |x|
              x.include? char
            end
          when 'v'
            V_CHARS.include? char
          when 'h'
            H_CHARS.include? char
          when 's'
            S_CHARS.include? char
          else
            warn "Unknown special char class name #{name}."
            false
          end
        end

        def accepted_names
          ['d', 'w', 's', 'v', 'h']
        end

      end

      class SpecialCharacterClass < AbsCharacterClass
        include SpecialCharacterClassMethods
        def as_json
          super.merge :name => name
        end
        def class_name
          'special'
        end
        alias_method :match_char?, :match_method
      end

      class InversedSpecialCharacterClass < SpecialCharacterClass
        include InversedCharacterClass
        alias_method :original_accepted_names, :accepted_names
        def accepted_names
          original_accepted_names.map(&:upcase)
        end
      end

      class SpecialCharacterClassItem
        include SpecialCharacterClassMethods
        public
        def as_json
          {
            :special => name
          }
        end
        alias_method :match?, :match_method
        public :match?
      end


    end
  end
end

