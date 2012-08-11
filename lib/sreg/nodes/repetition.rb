#
# Repetition, `a+`, `a*`, `a?`, `a{1,3}`, `a{,3}`, `a{1,}`, `a{3}`
# Sreg project
#
# Shou, 2 August 2012
#


module Sreg
  module Builder

    module AbstractSyntaxTree


      class RepetitionBuffer
        def initialize
        end

        def taken_part
        end
        def rest_part
        end

        def shift
        end
        def chop
        end

        def pos
        end

        def possible_repetition
        end
      end


      class AbsRepetition < Node
        Inf = -1

        attr_reader :min, :max
        attr_reader :member
        attr_reader :split_point
        attr_reader :repeat #TODO: rename to `repeats'

        def initialize(member, min, max)
          @member = member
          @member.parent = self

          # -1 == Infinity
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




        attr :repeat, :rest_repeat
        def length(but_one = false)
          return 0 unless @valid
          if but_one
            return 0 if @split_point - 1 <= 0
            return @repeat[0..(@split_point - 2)].inject(0, &:+)
          else
            return 0 if @split_point <= 0
            return @repeat[0..(@split_point - 1)].inject(0, &:+)
          end
        end

        # Abstract methods
        def compromise?
        end
        def compromise(str)
          reset_member_position(str)
        end

        def reset_member_position(str)
          # Damn it. This is just a very ugly solution.
          #+As this is not basically the best way for the
          #+exactly matching problem.
          # For solve this problem perfectly, the Repetition class need
          #+to be completely rewritten.

          # First, the matching method (i.e. match_time) needs
          #+to match string base on the behavior (i.e. greedy or lazy),
          #+min and max times, not just like this, match all and choose
          #+afterwards.

          # I suppose I'll do this tomorrow.

          if @split_point < 2
#            @member.set_invalid
            return
          end
          pos = @position
          pos += @repeat[0..(@split_point - 2)].inject(0, &:+)

          @member.reset(str, pos)
        end

        attr :valid
        def valid?
          @valid
        end

        def reset(string, position)
          super
          @repeat, open_end = match_time(string)

          if @split_point = pick_init_time(@repeat, open_end)
            reset_member_position(string)
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
          open_end = false
          while len = @member.reset(string, pos)
            if len == 0
              open_end = true
              break
            end
            length_arr << @member.length
            pos += length_arr.last
          end

          return [length_arr, open_end]
        end

        def pick_init_time(matches, open_end)
          # abstract method
          # return nil if fail, otherwise return the prior initial time
        end


      end

    end
  end
end
