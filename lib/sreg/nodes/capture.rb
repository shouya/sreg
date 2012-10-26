#
# Capture is a bunch of expression that will be used later.
#
#

require_relative '../ast'

module Sreg::Builder::AbstractSyntaxTree

  class Capture

    attr_accessor :member

    def initialize(member)
      @member = member
    end

    def optimize
      return self.class.new(member.optimize, *ext_init_args)
    end

    private
    def ref_table
      return reg_obj.ref_table
    end
    def ext_init_args
      []
    end
  end
end
