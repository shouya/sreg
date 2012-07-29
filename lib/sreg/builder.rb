#
# This file belongs to Sreg project
#
# Shou Ya, 30 July, 2012
#
#

module Sreg

  module Builder

    class Bunch

      attr_reader :elements
      def initialize(elements = [])
        @elements = elements
      end
      def append(element)
        @elements << element
      end

    end

    class AnyCharacter
    end

    class Character

      attr_reader :character
      def initialize(character)
        @character = character
      end

    end

    class Group

      attr_reader :member
      def initialize(member)
        @member = member
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

    end


    class CharacterClassItemCharacter
      attr_reader :character

      def initialize(character)
        @character = character
      end
    end
    class CharacterClassItemRange
      attr_reader :begin_x, :end_x
      def initialize(begin_x, end_x)
        @begin_x = begin_x
        @end_x = end_x
      end
    end


    class CharacterClass

      attr_reader :elements
      def initialize(elements)
        @elements = elements
      end
      def append(element)
        @elements << element
      end

    end


    class Group

      attr_reader :member
      def initialize(member)
        @member = member
      end

    end

  end
end
