#
# Abstract `node` class of Regular Expression Object
#
# Shou, 1 August 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree


      class Node

        attr_reader :position
        attr_accessor :parent

        def initialize
        end

        # Compile time
        def as_json
        end
        def to_s
        end
        def inspect
        end
        def match_result(string)
          as_json.merge(:match => string[@position, length])
        end

        def optimize
          self
        end


        # Run time
        def length
        end

        def compromise?
        end
        def compromise
        end
        def valid?
        end

        def reset(string, position)
          @position = position
          nil
        end

        # For optimization, not used now
        def min_length
          0
        end

      end
    end
  end
end
