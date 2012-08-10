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




        attr :repeat, :rest_repeat
        def length
          @valid ? @repeat.inject(0, &:+) : 0
        end

        def compromise?
#          @repeat and @repeat.length > @min
        end
        def compromise(*)
          @repeat.pop
        end

        attr :valid
        def valid?
          @valid
        end

        def reset(string, position)
          super
          repeat = match_time(string)

          if repe_time = pick_init_time(repeat)
            @repeat = repeat[0, repe_time]
            @rest_repeat = repeat[repe_time..-1]
            @valid = true
            return length
          end


          @valid = false
          return false
        end

        def optimize
          optimized_member = @member.optimize
          return self.class.new(optimized_member, @min, @max)
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
          length_arr = []
          pos = @position
          while len = @member.reset(string, pos)
            break if len == 0
            length_arr << @member.length
            pos += @member.length
          end

          unless length_arr.empty?
            @member.reset(string, pos - length_arr.last)
#            @member.instance_variable_set(:@position, pos - length_arr.last)
          end

          length_arr
        end

        def pick_init_time(matches)
          # abstract method
          # return nil if fail, otherwise return the prior initial time
        end


      end

    end
  end
end
