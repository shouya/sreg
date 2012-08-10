#
# Repetition, `a+`, `a*`, `a?`, `a{1,3}`, `a{,3}`, `a{1,}`, `a{3}`
# Sreg project
#
# Shou, 2 August 2012
#


module Sreg
  module Builder

    module AbstractSyntaxTree



      class GreedyRepetition < AbsRepetition

        def as_json
          super.merge(:behavior => :greedy)
        end
        def to_s
          super
        end

        def compromise?
          @repeat and @repeat.length > @min
        end
        def compromise(*)
          @repeat.pop
        end

        def pick_init_time(matches)
          repe_time = matches.length
          if repe_time >= @min
            if repe_time >= expand(@max)
              return @max
            else
              return repe_time
            end
          end
          return nil
        end


      end

    end
  end
end
