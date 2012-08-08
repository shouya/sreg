#
# Group, a match group, `(abc)`
# Sreg project
#
# Shou, 1 August 2012
#


module Sreg
  module Builder
    module AbstractSyntaxTree

      class Group < Node

        attr_reader :member
        def initialize(member)
          @member = member
          @member.parent = self
        end

        # Compile time
        def as_json
          {
            :group => @member.as_json
          }
        end

        def match_result(string)
          {
            :group => @member.match_result,
            :match => string[@position, length]
          }
        end

        def to_s
          "(#{@member.to_s})"
        end

        # Run time
        def length
          @member.length
        end

        def compromise?
          @member.compromise?
        end
        def compromise
          @member.compromise
        end
        def valid?
          @member.valid?
        end

        def reset(rest_string, position)
          super
          @member.reset(rest_string, position)
        end



      end


    end
  end
end
