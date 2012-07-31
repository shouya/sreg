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
    : atom '+'             { Repetition.new(val[0], 1, Repetition::Inf) }
    | atom '*'             { Repetition.new(val[0], 0, Repetition::Inf) }
    | atom '?'             { Repetition.new(val[0], 0, 1) }
    | atom VAR_REPETITION  { Repetition.new(val[0], val[1][0], val[1][1]) }
    ;


char_class_item
    : CHAR                 { CharacterClassItemCharacter.new(val[0]) }
    | CHAR '-' CHAR        { CharacterClassItemRange.new(val[0], val[2]) }
/* and ANSI char groups, such as [:alpha:] */
    ;

char_class_items
    : char_class_item                   { CharacterClass.new([val[0]]) }
    | char_class_items char_class_item  { val[0].append(val[1]) }
    ;

char_class
    : '[' char_class_items ']'          { val[1] }
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
