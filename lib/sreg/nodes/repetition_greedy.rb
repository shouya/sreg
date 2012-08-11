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
#          return false unless valid?
          return false unless @split_point
          return false if @split_point > @min
          return true
        end
        def compromise(*)
          @split_point -= 1
        end

        def pick_init_time(matches, open_end)
          repe_time = matches.length

          if open_end
            return @min if @min > repe_time
            return repe_time if @max == Inf
            return @max
          end

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
