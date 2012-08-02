

require 'test/unit'

require '../lib/sreg/lexer'


class TestLexer < Test::Unit::TestCase


  def build_lexer(init_string, debug = false)
    lexer = Sreg::Builder::Lexer.new({ :debug => debug })
    lexer.set_input_string(init_string)
    return lexer
  end



  def test_group
    assert_equal(build_lexer('(6)*)').tokens[0..-2],
                 [['(', nil], [:CHAR, '6'], [')', nil],
                  ['*', nil], [:CHAR, ')']])
    assert_equal(build_lexer('()').tokens[0..-2],
                 [['(', nil], [')', nil]])

  end

  def test_repetition
    assert_equal(build_lexer('{1,5}').tokens[0..-2],
                 [[:VAR_REPETITION, [1,5]]])
    assert_equal(build_lexer('{,5}').tokens[0..-2],
                 [[:VAR_REPETITION, [0,5]]])
    assert_equal(build_lexer('{1,}').tokens[0..-2],
                 [[:VAR_REPETITION, [1,-1]]])

    assert_raise Sreg::Builder::LexerError do
      build_lexer('{,}').tokens[0..-2]
    end

    assert_raise Sreg::Builder::LexerError do
      build_lexer('{5,1}').tokens[0..-2]
    end

    assert_raise Sreg::Builder::LexerError do
      build_lexer('{.,.}').tokens[0..-2]
    end

  end


  def test_repetition_regular
    assert_equal(build_lexer('**').tokens[0..-2], [['*', nil], ['*', nil]])
    assert_equal(build_lexer('+*').tokens[0..-2], [['+', nil], ['*', nil]])
    assert_equal(build_lexer('?+').tokens[0..-2], [['?', nil], ['+', nil]])
  end


  def test_dot
    assert_equal(build_lexer('.').tokens[0..-2], [['.', nil]])
  end

  def test_escaping
    assert_equal(build_lexer('\.').tokens[0..-2], [[:CHAR, '.']])
    assert_equal(build_lexer('\*?').tokens[0..-2], [[:CHAR, '*'], ['?', nil]])
    assert_equal(build_lexer('\(').tokens[0..-2], [[:CHAR, '(']])
    assert_equal(build_lexer('\]').tokens[0..-2], [[:CHAR, ']']])
    assert_equal(build_lexer('\\\\').tokens[0..-2], [[:CHAR, '\\']])
  end


  def test_char_class
    assert_equal(build_lexer(']').tokens[0..-2], [[:CHAR, ']']])
    assert_equal(build_lexer('[]').tokens[0..-2], [['[', nil], [']', nil]])
    assert_equal(build_lexer('[.]').tokens[0..-2],
                 [['[', nil], [:CHAR, '.'], [']', nil]])
    assert_equal(build_lexer('[()]').tokens[0..-2],
                 [['[', nil], [:CHAR, '('], [:CHAR, ')'], [']', nil]])
    assert_equal(build_lexer('[[]]').tokens[0..-2],
                 [['[', nil], [:CHAR, '['], [']', nil], [:CHAR, ']']])
    assert_equal(build_lexer('[a-b]').tokens[0..-2],
                 [['[', nil],
                  [:CHAR, 'a'], ['-', nil], [:CHAR, 'b'],
                  [']', nil]])
  end

end


