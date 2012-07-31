#
# AST module of Sreg project, providing relavant AST node classes
#
# Shou Ya, 31 July
#



module Sreg
  module Builder

    module AbstractSyntaxTree


      class Bunch

        attr_reader :elements
        def initialize(elements = [])
          @elements = elements
        end
        def append(element)
          @elements << element
          self
        end

        def as_json
          elements.map(&:as_json)
        end

        def to_s
          elements.map(&:to_s).join
        end

      end

      class AnyCharacter
        def as_json
          {
            :any_character => nil
          }
        end
        def to_s
          '.'
        end
      end

      class Character

        attr_reader :character
        def initialize(character)
          @character = character
        end

        def as_json
          {
            :character => @character
          }
        end
        def to_s
          @character.inspect[1..-2] # remote surrounding quote marks
        end
      end

      class Group

        attr_reader :member
        def initialize(member)
          @member = member
        end

        def as_json
          {
            :group => @member.as_json
          }
        end
        def to_s
          "(#{@member.to_s})"
        end
      end


      class Repetition
        Inf = -1

        attr_reader :min, :max
        attr_reader :member

        def initialize(member, min, max)
          @member = member

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

      end


      class CharacterClassItemCharacter
        attr_reader :character

        def initialize(character)
          @character = character
        end
        def as_json
          {
            :char => @character
          }
        end
        def to_s
          @character.inspect[1..-2] # remove surrounding quote marks
        end
      end
      class CharacterClassItemRange
        attr_reader :begin_x, :end_x
        def initialize(begin_x, end_x)
          if begin_x > end_x
            raise(Sreg::SyntaxError,
                  'Range defining in character class is illegal.')
          end
          @begin_x = begin_x
          @end_x = end_x
        end
        def as_json
          {
            :range_begin => @begin_x,
            :range_end => @end_x
          }
        end
        def to_s
          # remove surrounding quote marks
          "#{@begin_x.inspect[1..-2]}-#{@end_x.inspect[1..-2]}"
        end
      end


      class CharacterClass

        attr_reader :elements
        def initialize(elements)
          @elements = elements
        end
        def append(element)
          @elements << element
          self
        end

        def as_json
          {
            :char_class => @elements.map(&:as_json)
          }
        end

        def to_s
          "[#{@elements.map(&:to_s).join}]"
        end
      end






    end


  end
end
