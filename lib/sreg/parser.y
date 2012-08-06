# -*- bison -*-
#
# Regular Expression syntax parser of Sreg project
#
#
# Shou Ya, 30 July
#


class Sreg::Builder::Parser


options no_result_var


start main_rule


rule

main_rule
    : bunch
    ;

group
    : '(' bunch ')'        { Group.new(val[1]) }
    ;

repetition
    : meta_repetition      {
            GreedyRepetition.new(val[0][0], val[0][1], val[0][2])
        }
    | meta_repetition '?'  {
            LazyRepetition.new(val[0][0], val[0][1], val[0][2])
        }
    ;

meta_repetition
    : atom '+'             { [val[0], 1, AbsRepetition::Inf] }
    | atom '*'             { [val[0], 0, AbsRepetition::Inf] }
    | atom '?'             { [val[0], 0, 1] }
    | atom VAR_REPETITION  { [val[0], val[1][0], val[1][1]] }
    ;


char_class_item
    : CHAR                 { CharacterClassItemCharacter.new(val[0]) }
    | CHAR '-' CHAR        { CharacterClassItemRange.new(val[0], val[2]) }
    | SPEC_CHAR_CLASS      { SpecialCharacterClassItem.new(val[0]) }
      /* and POSIX char groups, such as [:alpha:] */
    ;

char_class_items
    : char_class_item                   { [val[0]] }
    | char_class_items char_class_item  { val[0] << val[1] }
    ;

custom_char_class
    : '[' char_class_items ']'    { CustomCharacterClass.new(val[1]) }
    | '[^' char_class_items ']'   { InversedCustomCharacterClass.new(val[1]) }
    ;

special_char_class
    : SPEC_CHAR_CLASS        { SpecialCharacterClass.new(val[0]) }
    | SPEC_CHAR_CLASS_INV    { InversedSpecialCharacterClass.new(val[0]) }
    ;

char_class
    : custom_char_class
    | special_char_class
    ;



atom
    : CHAR                              { Character.new(val[0]) }
    | group                             { val[0] }
    | char_class                        { val[0] }
    | '.'                               { AnyCharacter.new }
/* and char groups, such as '\d', '\s' */
    ;


bunch
    : /* Nothing */                     { Bunch.new([]) }
    | bunch atom                        { val[0].append(val[1]) }
    | bunch repetition                  { val[0].append(val[1]) }
    ;


end
