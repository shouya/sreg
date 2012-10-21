#
# EOL Assertion, '$'
# End of Line(EOL) will return matched if the position of the string is at
#+the end. (Currently multiple line matching is not supported yet.)
#
# Sreg Project
#
# (c) Shou, 9 August 2012
#

class Sreg
  module Builder
    module AbstractSyntaxTree


      class EOLAssertion < Assertion

        def as_json
          {
            :assertion => :eol
          }
        end
        def to_s
          '$'
        end


        def conform_to?(str, pos)
          return str.length == pos
        end

      end


    end
  end
end


