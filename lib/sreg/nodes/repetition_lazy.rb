#
# Repetition, `a+`, `a*`, `a?`, `a{1,3}`, `a{,3}`, `a{1,}`, `a{3}`
# Sreg project
#
# Shou, 2 August 2012
#


module Sreg
  module Builder

    module AbstractSyntaxTree




      class LazyRepetition < AbsRepetition
        def as_json
          super.merge(:behavior => :lazy)
        end
        def to_s
          super + '?'
        end

        def compromise?
          !@rest_repeat.empty? and @repeat.length < expand(@max)
        end
        def compromise(*)
          @repeat.push(@rest_repeat.shift)
        end

        def pick_init_time(matches)
          # abstract method
          # return nil if fail, otherwise return the prior initial time
          repe = matches.length
          if repe > @min
            return @min
          end
          nil
        end


      end

    end
  end
end
