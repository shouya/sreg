#
# CharacterClass, `[0-9a-zA-Z_]`
# Sreg project
#
# Shou, 1 August 2012
module Sreg
  module Builder

    module AbstractSyntaxTree

      class AbsCharacterClass < Node

        def initialize
          @valid = nil
        end

        # Compile time
        def as_json
          {
            :char_class => class_name
          }
        end

        # Abstract method
        def to_s
        end

        # Run time
        def length
          1
        end

        def compromise?
          false
        end
        def compromise
          nil
        end

        attr :valid
        def valid?
          return @valid
        end

        def reset(rest_string)
          unless rest_string.length > 1
            @valid = false
            return false
          end

          if match_char?(rest_string[0])
            @valid = true
            return 1
          end

          @valid = false
          return false
        end

        private
        # Abstract method
        def match_char?(char)
          # determine if this char class mathes the character,
          # and return true or false
        end

        # Abstract method
        def class_name
          # return a string that is the name of this char class
        end

      end

    end
  end
end
