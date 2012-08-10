#
# Alternation, `abc|cba`
# Sreg project
#
# (c) Shou, August 10 2012
#

module Sreg
  module Builder

    module AbstractSyntaxTree

      class Alternation < Node

        attr :choices, :selected
        def initialize(bunches)
          @choices = bunches
          @selected = nil
        end

        def as_json
          {
            :alternation => @choices
          }
        end

        def compromise?
          false
        end
        def compromise
          nil
        end
        def length
          @valid ? @selected.length : 0
        end

        def reset(str, pos)
          @choices.each do |x|
            if x.reset(str, pos)
              @valid = true
              @selected = x
              return x.length
            end
          end

          @valid = false
          return false
        end

      end


    end
  end
end
