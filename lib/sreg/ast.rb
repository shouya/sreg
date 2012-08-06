#
# AST module of Sreg project, providing relavant AST node classes
#
# Shou Ya, 31 July
#



module Sreg
  module Builder

    module AbstractSyntaxTree
      $LOAD_PATH << File.join(File.dirname(__FILE__), 'nodes')

      # Abstract treenode root
      autoload(:Node, 'node.rb')


      # Character class
      autoload(:AbsCharacterClass, 'char_class')
      autoload(:CustomCharacterClass, 'custom_char_class')
      autoload(:SpecialCharacterClass, 'special_char_class')

      # Inversed character class
      autoload(:InversedCharacterClass, 'inv_char_class') # M
      autoload(:InversedCustomCharacterClass, 'custom_char_class')
      autoload(:InversedSpecialCharacterClass, 'special_char_class')

      # Character class item
      autoload(:CharacterClassItemRange, 'char_class_range')
      autoload(:CharacterClassItemCharacter, 'char_class_char')
      autoload(:SpecialCharacterClassItem, 'special_char_class')

      # Repetition
      autoload(:AbsRepetition, 'repetition')
      autoload(:LazyRepetition, 'repetition_lazy')
      autoload(:GreedyRepetition, 'repetition_greedy')

      # Other
      autoload(:Character, 'char')
      autoload(:Group, 'group')
      autoload(:Bunch, 'bunch')
      autoload(:AnyCharacter, 'any_char')


    end


  end
end
