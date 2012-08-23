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
    end


    attr_reader :regexp
    attr_reader :string
    attr_reader :length


    attr :match_beg
    attr :match_len

    attr :match_caps


    def initialize
      @match_caps = []
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
      @match_caps[idx] = val
    end

    def to_a
      arr = [] << @string[@match_beg, @match_len]
      @match_caps.each do |(pos, len)|
        arr << @string[pos, len]
      end
      arr
    end

    private
    def set_match(str, pos, len)
      @string = str
      @match_beg = pos
      @match_len = len
    end

  end
end
