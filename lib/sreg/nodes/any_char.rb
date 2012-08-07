#
# AnyCharacter, (.)
# Sreg project
#
# Shou, 1 August 2012
#

module Sreg
  module Builder
    module AbstractSyntaxTree

      class AnyCharacter < Node

        def initialize
          super
          @valid = nil
        end

        # Compile time
        def as_json
          {
            :any_char => nil
          }
        end
        def to_s
          '.'
        end

        # Run time
        def length
          @valid ? 1 : 0
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

        def reset(string, position)
          super
          if position < string.length
            @valid = true
            return 1
          end
          @valid = false
          return false
        end


      end


    end
  end
end
