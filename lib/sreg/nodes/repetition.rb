#
# Repetition, `a+`, `a*`, `a?`, `a{1,3}`, `a{,3}`, `a{1,}`, `a{3}`
# Sreg project
#
# Shou, 2 August 2012
#


module Sreg
  module Builder

    module AbstractSyntaxTree

      class AbsRepetition < Node
        Inf = -1

        attr_reader :min, :max
        attr_reader :member

        def initialize(member, min, max)
          @member = member
          @member.parent = self

          @min = min
          @max = max
        end
        def as_json
          {
            :repetition => @member.as_json,
            :min => @min,
            :max => @max
          }
        end

        def match_result(string)
          {
            :repetition => @member.match_result(string),
            :min => @min,
            :max => @max,
            :match => string[@position, length]
          }
        end


        def to_s
          tmp = @member.to_s
          if @min == @max
            tmp << "{#{@min}}"
          elsif @min == 0 and @max == Inf
            tmp << '*'
          elsif @min == 1 and @max == Inf
            tmp << '+'
          elsif @min == 0 and @max == 1
            tmp << '?'
          elsif @min == Inf
            tmp << "{,#{@max}}"
          elsif @max == Inf
            tmp << "{#{@min},}"
          else
            tmp << "{#{@min},#{@max}}"
          end
          tmp
        end

        def optimize

          new_member = @member.optimize

          if @min == @max
            return Bunch.new([new_member] * @min).optimize
          end

          return self.class.new(new_member, min, max)
        end

        private
        def expand(number)
          if number == Inf
            return (1.0/0.0)
          end
          return number
        end

      end


    end
  end
end
