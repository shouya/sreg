#
# CharacterClassItemRange,
#   A possible range of chracters in a character class, form likes `[a-z]`
# Sreg project
#
# Shou, 1 August 2012
#

class Sreg
  module Builder
    module AbstractSyntaxTree

      class CharacterClassItemRange
        attr_reader :range
        def initialize(first, last)
          if first > last
            raise(Sreg::SyntaxError,
                  'Range defining in character class is illegal.')
          end
          @range = (first..last)
        end

        # Compile time
        def as_json
          {
            :range_begin => @range.first,
            :range_end => @range.last
          }
        end
        def to_s
          # remove surrounding quote marks
          "#{@range.first.inspect[1..-2]}-#{@range.last.inspect[1..-2]}"
        end


        # Run time
        def match?(char)
          @range.include? char
        end

      end

    end


  end
end

