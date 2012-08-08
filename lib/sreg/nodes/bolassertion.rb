#
# BOL Assertion, '$'
# Beginning of Line(EOL) will return matched if the position of the string is
#+at the beginning. (Currently multiple line matching is not supported yet.)
#
# Sreg Project
#
# (C) Shou, 9 August 2012
#

module Sreg
  module Builder
    module AbstractSyntaxTree


      class BOLAssertion < Assertion

        def as_json
          {
            :assertion => :bol
          }
        end
        def to_s
          '^'
        end

        def conform_to?(str, pos)
          return pos == 0
        end

      end


    end
  end
end


