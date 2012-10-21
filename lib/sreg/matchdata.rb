#
# Sreg::MatchData, detailed match information class
# Sreg project
#
# (c) Shou Ya, 16 August 2012
#

class Sreg
  class MatchData

    class << self
      alias_method :_alloc, :new
      private :_alloc
      undef_method :new

      private
      def build(str, mtch_pos, mtch_len)
        obj = _alloc
        obj.instance_variable_set :@string, str
        obj.instance_variable_set :@match_begin, mtch_pos
        obj.instance_variable_set :@match_length, mtch_len
        obj
      end
    end

    attr_reader :regexp
    attr_reader :string
    attr_reader :length


    attr :match_begin
    attr :match_length

    attr :match_captures


    def initialize
      @match_captures = []
    end


    def [](a, b = nil)
      case a

      when Range
        return to_a[a]

      when Symbol, String
        return to_a[@regexp.ref_table.name2no(a) + 1]

      when Integer
        return b == nil ? to_a[a] : to_a[a, b]

      end
    end


    def []=(idx, val)
      @match_captures[idx] = val
    end

    def to_a
      arr = [] << @string[@match_begin, @match_length]
      @match_captures.each do |(pos, len)|
        arr << @string[pos, len]
      end
      arr
    end

    private
    def set_capture(index, pos, len)
      @match_captures[index] = [pos, len]
    end

  end
end
