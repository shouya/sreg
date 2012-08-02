#
# Repetition, `a+`, `a*`, `a?`, `a{1,3}`, `a{,3}`, `a{1,}`, `a{3}`
# Sreg project
#
# Shou, 2 August 2012
#


module Sreg
  module Builder

    module AbstractSyntaxTree




      class Repetition < Node
        Inf = -1

        attr_reader :min, :max
        attr_reader :member

        def initialize(member, min, max)
          @member = member

          # -1 == Infinity
          @min = min
          @max = max

          @repeat = nil
        end

        def as_json
          {
            :repetition => @member.as_json,
            :min => @min,
            :max => @max
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
        def match(*)
          return as_json.merge(:match => @repeat)
        end



        attr :repeat
        def length
          @repeat.map(&:first).inject(0, &:+)
        end

        def compromise?
          @repeat and @repeat.length > @min
        end
        def compromise(*)
          @repeat.pop
        end

        attr :valid
        def valid?
          @valid
        end

        def reset(rest_string)
          repeat = match_time(rest_string)

          if repeat.length == 0
            return false
          else
            repe_time = repeat.length
            if repe_time >= @min and repe_time <= expand(@max)
              @valid = true
              @repeat = repeat
              return length
            end
          end

          @valid = false
          return false
        end

        private
        # Expand inifinities
        def expand(number)
          if number == Inf
            return (1.0/0.0)
          end
          return number
        end

        def match_time(string)
          arr = []
          while len = @member.reset(string)
            break if len == 0
            arr << [len, string[0, len]]
            string = string[len..-1]
          end

          arr
        end

      end

    end
  end
end
