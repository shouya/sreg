#
# String, as a shortcut for mulitple characters
#
# Sreg project
#
# (c) Shou August 10, 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree

      class String < Node

        attr_accessor :string
        def initialize(char_list)
          @string = char_list.join
        end

        def as_json
          { :string => @string }
        end

        def to_s
          @string.inspect[1..-2]
        end

        def length
          @valid ? @string.length : 0
        end

        attr :valid
        def valid?
          return @valid
        end

        def reset(str, pos)
          super
          if str[pos, @string.length] == @string
            @valid = true
            return @string.length
          end

          @valid = false
          return false
        end


      end


    end
  end
end

