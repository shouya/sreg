#
# Sreg AST builder of Sreg project
#
# Shou Ya, 30 July, 2012
#
#

class Sreg

  module Builder
    $LOAD_PATH << File.dirname(__FILE__)

    autoload :Constructor, 'constructor'
    autoload :Lexer, 'lexer'
    autoload :Parser, 'parser.tab' # Racc generated file
    autoload :AbstractSyntaxTree, 'ast'


  end

end
