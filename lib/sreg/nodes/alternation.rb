#
# Alternation, `abc|cba`
# Sreg project
#
# (c) Shou, August 10 2012
#

module Sreg
  module Builder

    module AbstractSyntaxTree

      class Alternation < Node

        attr :choices, :selected_index
        def initialize(bunches)
          @choices = bunches
          @selected_index = nil
        end
        def append(bunch)
          @choices.push bunch
          self
        end

        def as_json
          {
            :alternation => @choices.map(&:as_json)
          }
        end

        def length
          @valid ? @choices[@selected_index].length : 0
        end

        def backtrack(str)
          old_selected_index = @selected_index

          return true if @choices[@selected_index].backtrack(str)

          @selected_index += 1
          while @selected_index < @choices.length
            return true if @choices[@selected_index].reset(str, @position)
            @selected_index += 1
          end

          @selected_index = old_selected_index

          return false
        end

        def reset(str, pos)
          super
          @choices.each_with_index do |x, idx|
            if x.reset(str, pos)
              @valid = true
              @selected_index = idx
              return x.length
            end
          end

          @valid = false
          return false
        end

        def optimize
          new_choices = []
          @choices.each do |x|
            new_choices << x.optimize
          end

          if new_choices.length == 1
            return new_choices[0]
          else
            return Alternation.new(new_choices)
          end

        end

      end


    end
  end
end
