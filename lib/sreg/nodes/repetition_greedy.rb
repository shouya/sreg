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

        def compromise?(*)
          return false if @length_list.length == @min
          return true
        end

        def compromise(string)
          @length_list.pop
          @member.reset(string, @length_list.inject(0, &:+))
        end

        def reset(string, position)
          super

          match_arr = []

          pos = @position

          loop do
            break if match_arr.length == @max
            if @max == Inf and match_arr.last == 0
              break
            end

            unless @member.reset(string, pos)
              return false if match_arr.length < @min

              unless match_arr.empty?
                @member.reset(string, pos - match_arr.last)
              end
              break

            end

            match_arr << @member.length
            pos += match_arr.last
          end

          @length_list = match_arr
          return length
        end

        def length
          @length_list.inject(0, &:+)
        end

      end


    end
  end
end
