require '../lib/sreg/builder'

require 'test/unit'

class TestParser < Test::Unit::TestCase

  def parse(string)
    p = Sreg::Builder::Constructor.new
    p.parse_string(string)
    p.do_parse
  end

  def test_plain
    assert_equal 'abcde', parse('abcde').to_s
    assert_equal(:any_char, parse('ab.de').as_json[2].keys[0])
  end

  def test_char_class
    assert_equal :char_class, parse('[abc]').as_json[0].keys[0]
    assert_equal :char_class, parse('[a-c]').as_json[0].keys[0]
    assert_equal([{:char => 'a'}, {:char => 'b'}, {:char => 'c'}],
                 parse('[abc]').as_json[0][:children])

    assert_equal({ :range_begin => 'a', :range_end => 'c' },
                 parse('[a-c]').as_json[0][:children][0])
    assert_equal([{:char => 'a'},
                  {:range_begin => 'b', :range_end => 'd'},
                  {:char => 'e'}],
                 parse('[ab-de]').as_json[0][:children])
  end

  def test_group
    assert_equal :group, parse('(a)').as_json[0].keys[0]
    assert_equal :group, parse('()').as_json[0].keys[0]
    assert_equal 3, parse('(a[b-c]d)').as_json[0].values[0].length
    assert_equal({:group => [{ :group => [{ :group => [
                                                       {:character => 'a'}
                                                      ]
                                         }]
                             }]
                 }, parse('(((a)))').as_json[0])
  end


  def test_repetition
    inf = -1

    assert_equal :repetition, parse('a+').as_json[0].keys[0]
    assert_equal :repetition, parse('a?').as_json[0].keys[0]
    assert_equal :repetition, parse('a*').as_json[0].keys[0]
    assert_equal :repetition, parse('a{,3}').as_json[0].keys[0]
    assert_equal :repetition, parse('a{1,}').as_json[0].keys[0]
    assert_equal :repetition, parse('a{1,3}').as_json[0].keys[0]
    assert_equal :repetition, parse('a{2}').as_json[0].keys[0]

    assert_equal :greedy, parse('a+').as_json[0][:behavior]
    assert_equal :greedy, parse('a?').as_json[0][:behavior]
    assert_equal :greedy, parse('a*').as_json[0][:behavior]
    assert_equal :greedy, parse('a{,3}').as_json[0][:behavior]
    assert_equal :greedy, parse('a{1,}').as_json[0][:behavior]
    assert_equal :greedy, parse('a{1,3}').as_json[0][:behavior]
    assert_equal :greedy, parse('a{2}').as_json[0][:behavior]


    assert_equal 3, parse('(abc)+').as_json[0].values[0].values[0].length
    assert_equal 3, parse('([a]+(b)?c)+').as_json[0].values[0].values[0].length

    assert_equal inf, parse('a+').as_json[0][:max]
    assert_equal inf, parse('a*').as_json[0][:max]
    assert_equal 1, parse('a?').as_json[0][:max]
    assert_equal inf, parse('a{1,}').as_json[0][:max]
    assert_equal 2, parse('a{,2}').as_json[0][:max]
    assert_equal 2, parse('a{1,2}').as_json[0][:max]
    assert_equal 2, parse('a{2}').as_json[0][:max]
    assert_equal 2, parse('a{2,2}').as_json[0][:max]


    assert_equal 1, parse('a+').as_json[0][:min]
    assert_equal 0, parse('a*').as_json[0][:min]
    assert_equal 0, parse('a?').as_json[0][:min]
    assert_equal 1, parse('a{1,}').as_json[0][:min]
    assert_equal 0, parse('a{,2}').as_json[0][:min]
    assert_equal 1, parse('a{1,2}').as_json[0][:min]
    assert_equal 2, parse('a{2}').as_json[0][:min]
    assert_equal 2, parse('a{2,2}').as_json[0][:min]
  end

  def test_repetition_lazy
    inf = -1

    assert_equal :repetition, parse('a+?').as_json[0].keys[0]
    assert_equal :repetition, parse('a??').as_json[0].keys[0]
    assert_equal :repetition, parse('a*?').as_json[0].keys[0]
    assert_equal :repetition, parse('a{,3}?').as_json[0].keys[0]
    assert_equal :repetition, parse('a{1,}?').as_json[0].keys[0]
    assert_equal :repetition, parse('a{1,3}?').as_json[0].keys[0]
    assert_equal :repetition, parse('a{2}?').as_json[0].keys[0]

    assert_equal :lazy, parse('a+?').as_json[0][:behavior]
    assert_equal :lazy, parse('a??').as_json[0][:behavior]
    assert_equal :lazy, parse('a*?').as_json[0][:behavior]
    assert_equal :lazy, parse('a{,3}?').as_json[0][:behavior]
    assert_equal :lazy, parse('a{1,}?').as_json[0][:behavior]
    assert_equal :lazy, parse('a{1,3}?').as_json[0][:behavior]
    assert_equal :lazy, parse('a{2}?').as_json[0][:behavior]

    assert_equal 3, parse('(abc)+?').as_json[0].values[0].values[0].length
    assert_equal 3, parse('([a]+(b)?c)+?').as_json[0].values[0].values[0].length

    assert_equal inf, parse('a+?').as_json[0][:max]
    assert_equal inf, parse('a*?').as_json[0][:max]
    assert_equal 1, parse('a??').as_json[0][:max]
    assert_equal inf, parse('a{1,}?').as_json[0][:max]
    assert_equal 2, parse('a{,2}?').as_json[0][:max]
    assert_equal 2, parse('a{1,2}?').as_json[0][:max]
    assert_equal 2, parse('a{2}?').as_json[0][:max]
    assert_equal 2, parse('a{2,2}?').as_json[0][:max]


    assert_equal 1, parse('a+?').as_json[0][:min]
    assert_equal 0, parse('a*?').as_json[0][:min]
    assert_equal 0, parse('a??').as_json[0][:min]
    assert_equal 1, parse('a{1,}?').as_json[0][:min]
    assert_equal 0, parse('a{,2}?').as_json[0][:min]
    assert_equal 1, parse('a{1,2}?').as_json[0][:min]
    assert_equal 2, parse('a{2}?').as_json[0][:min]
    assert_equal 2, parse('a{2,2}?').as_json[0][:min]
  end

  def test_posix_char_class
    assert_equal :ascii, parse('[[:ascii:]]').as_json[0][:children][0][:posix]
    assert_equal :ascii, parse('[a[:ascii:]]').as_json[0][:children][1][:posix]
    assert_equal :ascii, parse('[[:ascii:]1]').as_json[0][:children][0][:posix]
    assert_equal :ascii, parse('[a[:ascii:]1]').as_json[0][:children][1][:posix]
    assert_equal :digit, parse('[^[:digit:]]').as_json[0][:children][0][:posix]
    assert_equal true, parse('[^[:digit:]]').as_json[0][:inversed]
    assert_equal({:range_begin => ?a, :range_end => ?z },
                 parse('[a-z[:digit:]]').as_json[0][:children][0])
    assert_equal({:posix => :digit},
                 parse('[a-z[:digit:]]').as_json[0][:children][1])
  end

end
