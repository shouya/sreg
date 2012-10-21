#
# Character, any regular characters
#
# Shou, 1 August 2012
#

class Sreg
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
          @character.inspect[1..-2] # remove surrounding quote marks
        end

        # Run time
        def length
          @valid ? 1 : 0
        end

        attr :valid
        def valid?
          return @valid
        end

        def reset(string, position)
          super
          if string[position] == @character
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
