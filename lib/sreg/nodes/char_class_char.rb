#
# CharacterClassItemCharacter,
#   A possible character in a character class, form likes `[abc]`
# Sreg project
#
# Shou, 1 August 2012
#

module Sreg
  module Builder

    module AbstractSyntaxTree

      class CharacterClassItemCharacter # not a regular expression atom
        attr_reader :character

        def initialize(character)
          @character = character
        end

        # Compile time
        def as_json
          {
            :char => @character
          }
        end
        def to_s
          @character.inspect[1..-2] # remove surrounding quote marks
        end

        # Run time
        def match?(char)
          char == @character
        end

      end


    end
  end
end
