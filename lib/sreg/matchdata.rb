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

    attr :match_begin
    attr :match_length

    attr :match_captures

    def initialize
      @match_captures = []
    end


    def pos
      @match_begin
    end
    def length
      @match_length
    end
    alias_method :size, :length

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

    def to_a
      arr = [] << @string[@match_begin, @match_length]
      @match_captures.each do |(pos, len)|
        arr << @string[pos, len]
      end
      arr
    end

    def captures
      to_a[1..-1]
    end

    def ==(rhs)
      return false unless @string == rhs.string
      return false unless @regexp == rhs.regexp
      return false unless self.pos == rhs.pos
      return false unless self.length == rhs.length
      return false unless self.to_a == rhs.to_a
      return true
    end

    def offset(n)
      [@match_captures[n].first,
       @match_captures[n].last + @match_captures[n].first]
    end

    def post_match
      @string[0..pos]
    end
    def post_match
      @string[(pos+length)..-1]
    end

    def to_s
      @string[pos, length]
    end
    def values_at(*args)
      to_a.values_at(*args)
    end

    private
    def set_capture(index, pos, len)
      @match_captures[index] = [pos, len]
    end

  end
end
