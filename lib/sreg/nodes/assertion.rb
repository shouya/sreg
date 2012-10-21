#
# Abstract Assertion class of Sreg project
# Assertions are those doesn't match any character but
#+assert whether a specific condition is reached
#
# Shou, 9 August 2012
#


class Sreg
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
          as_json.merge(:match => @valid)
        end


        def length
          0
        end

        def reset(string, position)
          super
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
