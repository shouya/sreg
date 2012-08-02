#
# CharacterClass, `[0-9a-zA-Z_]`
# Sreg project
#
# Shou, 1 August 2012
module Sreg
  module Builder

    module AbstractSyntaxTree

      class CharacterClass < Node

        attr_reader :elements
        def initialize(elements)
          @elements = elements
          @valid = nil
        end
        def append(element)
          @elements << element
          self
        end

        # Compile time
        def as_json
          {
            :char_class => @elements.map(&:as_json)
          }
        end

        def to_s
          "[#{@elements.map(&:to_s).join}]"
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
          if @elements.any? {|e| e.match?(rest_string[0]) }
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
