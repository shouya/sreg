#
# Abstract `node` class of Regular Expression Object
#
# Shou, 1 August 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree


      class Node

        def initialize
        end

        # Compile time
        def as_json
        end
        def to_s
        end
        def inspect
        end
#        def match(string)
#          as_json.merge(:match => string[length])
#        end


        # Run time
        def length
        end

        def compromise?
        end
        def compromise
        end
        def valid?
        end

        def reset(rest_string)
        end

        # For optimization, not used now
        def min_length
          0
        end

      end
    end
  end
end
