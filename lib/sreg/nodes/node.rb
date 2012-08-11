#
# Abstract `node` class of Regular Expression Object
#
# Shou, 1 August 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree


      class Node

        attr_reader :position
        attr_accessor :parent

        def initialize
        end

        # return a JSON compatible object that describe self
        # (i.e. Hash, Array, Number, String, Boolean & Nil)
        def as_json
        end
        def to_s
        end
        def inspect
        end

        def match_result(string)
          as_json.merge(:match => string[@position, length])
        end

        # optimize self and children
        # return the new optimized node for replacing itself
        # or return `self` directly if there's no optimize ways
        def optimize
          self
        end


        def length
        end


        # return false if can't backtrack,
        # otherwise, backtrack and return a non-false value.
        def backtrack(string)
          false
        end

        # return if the node is matched validly.
        def valid?
        end

        def reset(string, position)
          @position = position
          nil
        end

        # for further optimization, not used now.
        def min_length
          0
        end

      end
    end
  end
end
