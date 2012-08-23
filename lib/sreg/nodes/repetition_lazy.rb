#
# Repetition, `a+`, `a*`, `a?`, `a{1,3}`, `a{,3}`, `a{1,}`, `a{3}`
# Sreg project
#
# Shou, 2 August 2012
#


class Sreg
  module Builder

    module AbstractSyntaxTree


      class LazyRepetition < AbsRepetition
        def as_json
          super.merge(:behavior => :lazy)
        end
        def to_s
          super + '?'
        end

        def backtrack(string)
          return false if @num_repeat == expand(@max)
          unless @member.reset(string, @position + @length)
            @member.reset(string, @position + @prev_length)
            return false
          end

          @prev_length = @length
          @length += @member.reset(string, @position + @length)
          @num_repeat += 1

          return true
        end

        def reset(string, position)
          super

          pos = @position
          match_arr = []

          loop do
            break if match_arr.length == @min

            return false unless @member.reset(string, pos)

            match_arr << @member.length
            pos += match_arr.last
          end

          @length = match_arr.inject(0, &:+)
          @prev_length = match_arr[0..-2].inject(0, &:+)
          @num_repeat = match_arr.length
          return @length
        end

        def length
          @length
        end

      end


    end
  end
end
