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
          return false unless @split_point
          @split_point <= expand(@max)
#          !@rest_repeat.empty? and @repeat.length < expand(@max)
        end
        def compromise(*)
          @split_point += 1
#          @repeat.push(@rest_repeat.shift)
          super
        end

        def pick_init_time(matches, open_end)
          # abstract method
          # return nil if fail, otherwise return the prior initial time
          repe_time = matches.length

          if repe_time > @min or open_end
            return @min
          end

          nil
        end


      end

    end
  end
end
