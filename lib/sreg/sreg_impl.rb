#
# Implmenent of Sreg object (instance & class methods)
# Sreg Project
#
# (c) Shou 16 August 2012
#

require_relative 'builder'
require_relative 'matchdata'
require_relative 'ref_table'

class Sreg
  module InstanceMethods
    attr_reader :source

    attr_reader :regexp
    attr_reader :match_result
    attr_reader :ref_table

    attr_reader :options

    def initialize(regexp, options = {})
      @source = regexp
      @options = options

      @ref_table = ReferenceTable.new

      cons = Sreg::Builder::Constructor.new(self)

      cons.parse_string(regexp)
      reg = cons.do_parse

      @regexp = reg
      @regexp = reg.optimize unless options[:O0]
    end

    def ==(rhs)
      return @regexp == rhs.regxp
    end

    def match(str, pos = 0)
      @source = str
      # TODO
    end

    def last_match(n = nil)
      return @match_result unless n

      return @match_result[n]
    end


    def match_pos(str)
      pos, _ = do_match(str)
      return pos if pos

      return nil
    end

    def do_match(str, start_pos = 0)
      0.upto(str.length) do |i|
        if len = @regexp.reset(str, i)
          set_match_result(str, i, len)
          return [i, len]
        end
      end
      return nil
    end

    def set_match_result(str, pos, len)
      # TODO: Finish this function
      # Refer data from `str` and the `@ref_table`,
      # then save the match result into the `@match_result`
      @match_result = MatchData.send(:build, str, pos, len)

      @ref_table.number_map.each_with_index do |ref_obj, n|
        @match_result.send :set_capture, n, ref_obj.position, ref_obj.length
      end
    end


    alias_method :=~, :match_pos
    public :=~
  end

  module ClassMethods
  end

end

