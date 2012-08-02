#
# Character, any regular characters
#
# Shou, 1 August 2012
#

module Sreg
  module Builder
    module AbstractSyntaxTree


      class Character < Node

        attr_reader :character
        def initialize(character)
          @character = character
          @valid
        end

        # Compile time
        def as_json
          {
            :character => @character
          }
        end
        def to_s
          @character.inspect[1..-2] # remote surrounding quote marks
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
          if rest_string[0] == @character
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
