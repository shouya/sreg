

require 'test/unit'

require '../lib/sreg/lexer'


class TestLexer < Test::Unit::TestCase


  def scan(init_string, debug = false)
    lexer = Sreg::Builder::Lexer.new({ :debug => debug })
    lexer.set_input_string(init_string)
    return lexer.tokens[0..-2]
  end

  def assert_lexical_error(expression)
    assert_raise Sreg::Builder::LexerError do scan(expression) end
  end

  def test_group
    assert_equal(scan('(6)*)'),
                 [['(', nil], [:CHAR, '6'], [')', nil],
                  ['*', nil], [:CHAR, ')']])
    assert_equal(scan('()'), [['(', nil], [')', nil]])

  end

  def test_repetition
    assert_equal(scan('{1,5}'), [[:VAR_REPETITION, [1,5]]])
    assert_equal(scan('{,5}'), [[:VAR_REPETITION, [0,5]]])
    assert_equal(scan('{1,}'), [[:VAR_REPETITION, [1,-1]]])

    assert_lexical_error('{,}')
    assert_lexical_error('{5,1}')
    assert_lexical_error('{.,.}')
  end


  def test_repetition_regular
    assert_equal(scan('**'), [['*', nil], ['*', nil]])
    assert_equal(scan('+*'), [['+', nil], ['*', nil]])
    assert_equal(scan('?+'), [['?', nil], ['+', nil]])
  end


  def test_dot
    assert_equal(scan('.'), [['.', nil]])
  end

  def test_escaping
    assert_equal(scan('\.'), [[:CHAR, '.']])
    assert_equal(scan('\*?'), [[:CHAR, '*'], ['?', nil]])
    assert_equal(scan('\('), [[:CHAR, '(']])
    assert_equal(scan('\]'), [[:CHAR, ']']])
    assert_equal(scan('\\\\'), [[:CHAR, '\\']])
    assert_equal(scan('\a'), [[:CHAR, "\a"]])
    assert_equal(scan('\e'), [[:CHAR, "\e"]])
    assert_equal(scan('\n'), [[:CHAR, "\n"]])
    assert_equal(scan('\0'), [[:CHAR, "\0"]])
    assert_equal(scan('\05'), [[:CHAR, "\05"]])
    assert_lexical_error('\08')
    assert_equal(scan('\x1'), [[:CHAR, "\x1"]])
    assert_equal(scan('\xaf'), [[:CHAR, "\xaf"]])
    assert_equal(scan('\x{af}'), [[:CHAR, "\xaf"]])
    assert_equal(scan('\x{aF}'), [[:CHAR, "\xaf"]])
    assert_equal(scan('\X{af}'), [[:CHAR, "\xaf"]])

    assert_lexical_error('\xG')
    assert_lexical_error('\x~')

    assert_equal(scan('\d'), [[:SPEC_CHAR_CLASS, 'd']])
    assert_equal(scan('\w'), [[:SPEC_CHAR_CLASS, 'w']])
    assert_equal(scan('\s'), [[:SPEC_CHAR_CLASS, 's']])

    assert_equal(scan('\D'), [[:SPEC_CHAR_CLASS_INV, 'D']])
    assert_equal(scan('\W'), [[:SPEC_CHAR_CLASS_INV, 'W']])
    assert_equal(scan('\S'), [[:SPEC_CHAR_CLASS_INV, 'S']])

    assert_equal(scan('\1'), [[:BACK_REFERENCE, 1]])
    assert_equal(scan('\12'), [[:BACK_REFERENCE, 12]])
  end


  def test_char_class
    assert_equal(scan(']'), [[:CHAR, ']']])
    assert_equal(scan('[]'), [['[', nil], [']', nil]])
    assert_equal(scan('[.]'), [['[', nil], [:CHAR, '.'], [']', nil]])
    assert_equal(scan('[()]'),
                 [['[', nil], [:CHAR, '('], [:CHAR, ')'], [']', nil]])
    assert_equal(scan('[[]]'),
                 [['[', nil], [:CHAR, '['], [']', nil], [:CHAR, ']']])
    assert_equal(scan('[a-b]'),
                 [['[', nil],
                  [:CHAR, 'a'], ['-', nil], [:CHAR, 'b'],
                  [']', nil]])
  end

end


