#
# Abstract Assertion class of Sreg project
# Assertions are those doesn't match any character but
#+assert whether a specific condition is reached
#
# Shou, 9 August 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree

      #
      # This class is designed for implementing zero-width assertion,
      #+and those look-around operations
      #
      class Assertion < Node
        # Abstract Methods
        def as_json
        end
        def to_s
        end

        def match_result(string)
          as_json.merge(:match => string[@position, length])
        end


        def length
          0
        end

        # Overridable
        def compromise?
          false
        end
        def compromise
          nil
        end

        def reset(string, position)
          @valid = conform_to?(string, position)
          return @valid ? length : false
        end

        private
        # Abstract method
        def conform_to?(str, pos)
        end


      end
    end
  end
end
