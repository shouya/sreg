require_relative '../lib/sreg'

require 'test/unit'

class TestMatching < Test::Unit::TestCase

  def compile(regexp, optimization = false)
    return Sreg.new(regexp, :O0 => !optimization)
  end

  def assert_match(regexp, string, length = nil)
    mtch_normal = (compile(regexp) =~ string)
    mtch_not_optimized = (compile(regexp, true) =~ string)

    assert_not_equal(nil, mtch_normal)
    assert_not_equal(nil, mtch_not_optimized)

    if length
      assert_equal(length, mtch_normal)
      assert_equal(length, mtch_not_optimized)
    end
  end

  def assert_not_match(regexp, string)
    assert_equal(0, compile(regexp) -~ string)
    assert_equal(0, compile(regexp, true) -~ string)
  end

  def test_basis
    assert_match('', '')
    assert_match('', 'a')
    assert_not_match('a', '')
  end

  def test_char
    assert_match('a', 'a', 1)
    assert_match('a', 'abc', 1)
    assert_match('abc', 'abc', 3)
  end

  def test_any_char
    assert_match('.', 'a', 1)
    assert_match('.', 'ab', 1)
    assert_match('..', 'ab', 2)
  end

  def test_char_class
    assert_match('[abc]', 'a')
    assert_match('[abc]', 'b')
    assert_match('[abc]', 'c')
    assert_not_match('[abc]', 'd')

    assert_match('[a-z]', 'a')
    assert_match('[a-z]', 'k')
    assert_match('[a-z]', 'z')
    assert_not_match('[a-z]', '1')

    assert_match('[123a-z]', '1')
    assert_match('[123a-z]', '3')
    assert_match('[123a-z]', 'a')
    assert_match('[123a-z]', 'z')
    assert_not_match('[123a-z]', '5')

    assert_match('[1-34-56-8]', '2')
    assert_match('[1-34-56-8]', '5')
    assert_match('[1-34-56-8]', '7')
    assert_not_match('[1-34-56-8]', '9')

    0.upto(9) do |x|
      assert_match('\d', x.to_s)
      assert_match('\w', x.to_s)
      assert_not_match('\D', x.to_s)
      assert_not_match('\W', x.to_s)
      assert_match('[[:alnum:]]', x.to_s)
      assert_match('[[:digit:]]', x.to_s)
      assert_match('[[:xdigit:]]', x.to_s)
      assert_not_match('[[:alpha:]]', x.to_s)
    end

    'a'.upto 'f' do |x|
      assert_match('\w', x)
      assert_not_match('\W', x)
      assert_match('[[:xdigit:]]', x)
      assert_match('[[:alpha:]]', x)
      assert_match('[[:lower:]]', x)
      assert_not_match('[[:upper:]]', x)
    end
    'A'.upto 'F' do |x|
      assert_match('\w', x)
      assert_not_match('\W', x)
      assert_match('[[:xdigit:]]', x)
      assert_match('[[:alpha:]]', x)
      assert_match('[[:upper:]]', x)
      assert_not_match('[[:lower:]]', x)
    end

    [' ', "\t", "\n", "\v", "\f"].each do |x|
      assert_match('[[:space:]]', x)
      assert_match('\s', x)
      assert_not_match('\S', x)
      assert_not_match('\w', x)
    end

    assert_match('[\d_]', '_')
    assert_match('[\d_]', '1')
    assert_not_match('[\d_]', 'a')

    assert_match('[\d\w]', '_')
    assert_match('[\d\w]', '1')
    assert_match('[\d\w]', 'a')
    assert_not_match('[\d\w]', ' ')

    assert_match('[\d[:alpha:]]', '1')
    assert_match('[\d[:alpha:]]', 'a')
    assert_match('[\d[:alpha:]]', 'A')
    assert_not_match('[\d[:alpha:]]', '_')

    assert_match('[[:alpha:][:digit:]]', 'a')
    assert_match('[[:alpha:][:digit:]]', '1')

    assert_match('[[]]', '[]')  # /[[]]/ == /[\[] \]/x == /\[\]/
    assert_not_match('[[]]', ']')

    assert_match('[[:digit:]a]', 'a')
    assert_match('[[:digit:]a]', '1')
    assert_not_match('[[:digit:]a]', 'b')

    assert_match('[[:digit:]a-z]', 'b')
    assert_match('[[:digit:]a]', '2')
    assert_not_match('[[:digit:]a]', 'A')
  end

  def test_repetition
    assert_match('.+', 'abc', 3)
    assert_match('.+?', 'abc', 1)

    assert_match('.*', 'abc', 3)
    assert_match('.*?', 'abc', 0)

    assert_match('.?', 'abc', 1)
    assert_match('.??', 'abc', 0)

    assert_match('\d{3,5}', '1234567', 5)
    assert_match('\d{3,5}?', '1234567', 3)

    assert_match('\w{3,5}', '1234 5', 4)
    assert_match('\w{3,5}?\s', '1234 5', 5)
    assert_match('\w{3,5}?', '1234 5', 3)

    assert_not_match('\d+', 'a')
    assert_not_match('\d+a', '12345b')

    assert_match('(..)+', '12345', 4)
    assert_match('(...)+', '12345678', 6)
    assert_match('((..)+)+', '12345', 4)

    assert_match('.+?.+?', '1234', 2)
    assert_match('(\w|\d)+', '12ab', 4)

    assert_match('()+a', 'a')
    assert_match('(){3,5}a', 'a', 1)

    assert_match('(a|){2,}b', 'ab', 2)
    assert_match('(a|){2,}?b', 'ab', 2)
  end

  def test_assertion
    # TODO: Some assertions of this test need `global shift' support
    # TODO: Word boundary support

#    assert_match('b', 'abc', 1)
    assert_not_match('^b', 'abc')
    assert_not_match('b$', 'abc')
#    assert_match('c$', 'abc', 1)
    assert_match('^a', 'abc', 1)
    assert_match('^a$', 'a', 1)
    assert_match('^$', '', 0)
    assert_not_match('^$', ' ')
  end


  def test_alternation
    assert_match('a|b|c', 'a', 1)
    assert_match('a|b|c', 'b', 1)
    assert_match('a|b|c', 'c', 1)
    assert_not_match('a|b|c', 'd')
    assert_match('ab|cd', 'cd', 2)
    assert_match('a(b|c)d', 'abd', 3)
    assert_match('a(b|c)d', 'acd', 3)
    assert_match('a(b|c|)d', 'ad', 2)
    assert_match('|||', '', 0)

    assert_match('(a+|b+)a', 'aa')
    assert_match('(a+|b+)b', 'bb')
    assert_match('(a+|b+)b', 'aab')

    assert_not_match('(a{2,3}|b{3,4})c', 'ac')
    assert_match('(a{2,3}|b{3,4})c', 'aac')
    assert_match('(a{2,3}|b{3,4})c', 'aaac')
    assert_not_match('(a{2,3}|b{3,4})c', 'aaaac')

    assert_not_match('(a{2,3}|b{3,4})c', 'c')
    assert_not_match('(a{2,3}|b{3,4})c', 'bbc')
    assert_not_match('(a{2,3}|b{3,4})c', 'abbc')
    assert_match('(a{2,3}|b{3,4})c', 'bbbc')
    assert_match('(a{2,3}|b{3,4})c', 'bbbbc')
    assert_not_match('(a{2,3}|b{3,4})c', 'bbbbbc')

    assert_match('(a+|b+)(c+|d+)(e+|f+)(g+|h+)',
                 'aaadddfhhhh')

    # TODO: Support for these (mainly lexer part)
    #    assert_match('^a|^b', 'a', 1)
    #    assert_match('^a|^b', 'b', 1)

  end

  def test_group
    # This is actually not needed, as above tests already qualified it.
    nil
  end
end

