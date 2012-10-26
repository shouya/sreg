#
# Named Capture
# Sreg prject
#
# Shou (c) 2012
#


require_relative '../ast'

module Sreg::Builder::AbstractSyntaxTree

  class NamedCapture < Capture

    attr_reader :name
    def initialize(*args, name)
      super(*args)
      @name = name
      register
    end

    def register
      ref_table.register_name(@name, self)
    end

    private
    def ext_init_args
      [@name]
    end

  end

end
