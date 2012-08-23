#
# Group, a match group, `(abc)`
# Sreg project
#
# Shou, 1 August 2012
#


class Sreg
  module Builder
    module AbstractSyntaxTree

      class Group < Node

        class << self
          alias_method :new_without_reindex, :new
          def new(*args)
            tmp = new_without_reindex(*args)
            tmp.register
            tmp
          end

          def new_reindex(*args, index)
            tmp = new_without_reindex(*args)
            tmp.register(index)
            tmp
          end

        end

        attr_reader :member, :ref_index
        # NOTICE: this method is not multiply callable as it may
        #+taint the reference table. So be careful in optimization stage.
        def initialize(member)
          @member = member
        end

        def register(n = nil)
          if reg_obj.ref_table.is_number_type?
            if n
              @ref_index = reg_obj.ref_table.set_number_map(n, self)
            else
              @ref_index = reg_obj.ref_table.insert_number_map(self)
            end
          end
        end

        # Compile time
        def as_json
          {
            :group => @member.as_json
          }
        end

        def match_result(string)
          {
            :group => @member.match_result(string),
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

        def backtrack(str)
          @member.backtrack(str)
        end

        def valid?
          @member.valid?
        end

        def reset(rest_string, position)
          super
          @member.reset(rest_string, position)
        end


        def optimize
          return Group.new_reindex(@member.optimize, @ref_index)
        end

      end


    end
  end
end
