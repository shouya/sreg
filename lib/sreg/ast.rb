#
# AST module of Sreg project, providing relavant AST node classes
#
# Shou Ya, 31 July
#



module Sreg
  module Builder

    module AbstractSyntaxTree
      $LOAD_PATH << File.join(File.dirname(__FILE__), 'nodes')


      autoload(:Node, 'node.rb')
      autoload(:Character, 'char')
      autoload(:CharacterClass, 'char_class')
      autoload(:CharacterClassItemRange, 'char_class_range')
      autoload(:CharacterClassItemCharacter, 'char_class_char')
      autoload(:Group, 'group')
      autoload(:Bunch, 'bunch')
      autoload(:AnyCharacter, 'any_char')
      autoload(:AbsRepetition, 'repetition')
      autoload(:LazyRepetition, 'repetition_lazy')
      autoload(:GreedyRepetition, 'repetition_greedy')


    end


  end
end
