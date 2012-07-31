#
# Regular expression object contructor of Sreg project
#
# Shou Ya, 30 July, 2012
#
#

require_relative './builder'

module Sreg

  module Builder

    class Constructor

      attr_accessor :scanner, :parser
      attr_accessor :options

      def initialize(options = {})
        @options = options

        @scanner = Lexer.new
        @parser = Parser.new

        @parser.singleton_class.send :include, self.ParserMethods
#        @parser.singleton_class.send :include, AbstractSyntaxTree

        # Temporary solution:
        @parser.class.send :include, AbstractSyntaxTree

      end

      def do_parse
        @parser.do_parse
      end

      def parse_string(str)
        @scanner.set_input_string(str)
      end


      # Mimic Method!
      def ParserMethods
        # Super Meta Stuff!
        me = self
        return Module.new do
          define_method :next_token do
            me.scanner.next_token
          end

          define_method :included do |who|
            who.alias_method :on_error_old, :on_error
          end
=begin
          define_method :on_error do |id, val, vstack|
            # error reporting
          end
=end

        end
      end
    end

  end
end
