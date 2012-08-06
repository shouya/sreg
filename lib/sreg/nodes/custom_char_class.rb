#
# CharacterClass, `[0-9a-zA-Z_]`
# Sreg project
#
# Shou, 1 August 2012
module Sreg
  module Builder

    module AbstractSyntaxTree

      class CustomCharacterClass < AbsCharacterClass

        attr_reader :elements
        def initialize(elements)
          super()
          @elements = elements
        end

        def append(element)
          @elements << element
          self
        end

        # Compile time
        def as_json
          super.merge(:children => @elements.map(&:as_json))
        end

        def to_s
          "[#{@elements.map(&:to_s).join}]"
        end

        def match_char?(char)
          return @elements.any? {|e| e.match?(char) }
        end

        def class_name
          'custom'
        end
      end

      class InversedCustomCharacterClass < CustomCharacterClass
        include InversedCharacterClass
      end

    end
  end
end
