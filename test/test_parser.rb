require '../lib/sreg'

require 'test/unit'

class TestParser < Test::Unit::TestCase

  def parse(string)
    p = Sreg.new(string)
#    p p.regexp.class

#    require 'ap'
    p.regexp
  end

  def test_plain
    assert_equal 'abcde', parse('abcde').to_s
    assert_equal(:any_char, parse('ab.de').as_json[1].keys[0])
  end

  def test_char_class
    assert_equal :char_class, parse('[abc]').as_json.keys.first
    assert_equal :char_class, parse('[a-c]').as_json.keys.first

    assert_equal([{:char => 'a'}, {:char => 'b'}, {:char => 'c'}],
                 parse('[abc]').as_json[:children])

    assert_equal({ :range_begin => 'a', :range_end => 'c' },
                 parse('[a-c]').as_json[:children][0])
    assert_equal([{:char => 'a'},
                  {:range_begin => 'b', :range_end => 'd'},
                  {:char => 'e'}],
                 parse('[ab-de]').as_json[:children])
    assert_raise(Racc::ParseError) { parse('[]') }

  end

  def test_group
    assert_equal :group, parse('(a)').as_json.keys[0]
    assert_equal :group, parse('()').as_json.keys[0]
    assert_equal 3, parse('(a[b-c]d)').as_json.values[0].length
    assert_equal({:group => { :group => { :group => {:string => 'a'}
                     }}}, parse('(((a)))').as_json)
  end


  def test_repetition
    inf = -1

    assert_equal :repetition, parse('a+').as_json.keys[0]
    assert_equal :repetition, parse('a?').as_json.keys[0]
    assert_equal :repetition, parse('a*').as_json.keys[0]
    assert_equal :repetition, parse('a{,3}').as_json.keys[0]
    assert_equal :repetition, parse('a{1,}').as_json.keys[0]
    assert_equal :repetition, parse('a{1,3}').as_json.keys[0]

    # proudly optimizqed
    assert_equal({ :string => 'aa' }, parse('a{2}').as_json)

    assert_equal :greedy, parse('a+').as_json[:behavior]
    assert_equal :greedy, parse('a?').as_json[:behavior]
    assert_equal :greedy, parse('a*').as_json[:behavior]
    assert_equal :greedy, parse('a{,3}').as_json[:behavior]
    assert_equal :greedy, parse('a{1,}').as_json[:behavior]
    assert_equal :greedy, parse('a{1,3}').as_json[:behavior]

    #    assert_equal :greedy, parse('a{2}').as_json[:behavior]


    assert_equal(3,
                 parse('(abc)+').as_json.values[0].values[0].values[0].length)
    assert_equal 3, parse('([a]+(b)?c)+').as_json.values[0].values[0].length

    assert_equal inf, parse('a+').as_json[:max]
    assert_equal inf, parse('a*').as_json[:max]
    assert_equal 1, parse('a?').as_json[:max]
    assert_equal inf, parse('a{1,}').as_json[:max]
    assert_equal 2, parse('a{,2}').as_json[:max]
    assert_equal 2, parse('a{1,2}').as_json[:max]
    #    assert_equal 2, parse('a{2}').as_json[:max]
    #    assert_equal 2, parse('a{2,2}').as_json[:max]


    assert_equal 1, parse('a+').as_json[:min]
    assert_equal 0, parse('a*').as_json[:min]
    assert_equal 0, parse('a?').as_json[:min]
    assert_equal 1, parse('a{1,}').as_json[:min]
    assert_equal 0, parse('a{,2}').as_json[:min]
    assert_equal 1, parse('a{1,2}').as_json[:min]
    #    assert_equal 2, parse('a{2}').as_json[:min]
    #    assert_equal 2, parse('a{2,2}').as_json[:min]
  end

  def test_repetition_lazy
    inf = -1

    assert_equal :repetition, parse('a+?').as_json.keys[0]
    assert_equal :repetition, parse('a??').as_json.keys[0]
    assert_equal :repetition, parse('a*?').as_json.keys[0]
    assert_equal :repetition, parse('a{,3}?').as_json.keys[0]
    assert_equal :repetition, parse('a{1,}?').as_json.keys[0]
    assert_equal :repetition, parse('a{1,3}?').as_json.keys[0]
    #    assert_equal :repetition, parse('a{2}?').as_json.keys[0]

    assert_equal :lazy, parse('a+?').as_json[:behavior]
    assert_equal :lazy, parse('a??').as_json[:behavior]
    assert_equal :lazy, parse('a*?').as_json[:behavior]
    assert_equal :lazy, parse('a{,3}?').as_json[:behavior]
    assert_equal :lazy, parse('a{1,}?').as_json[:behavior]
    assert_equal :lazy, parse('a{1,3}?').as_json[:behavior]
    #    assert_equal :lazy, parse('a{2}?').as_json[:behavior]

    assert_equal(3,
                 parse('(abc)+?').as_json.values[0].values[0].values[0].length)
    assert_equal 3, parse('([a]+(b)?c)+?').as_json.values[0].values[0].length

    assert_equal inf, parse('a+?').as_json[:max]
    assert_equal inf, parse('a*?').as_json[:max]
    assert_equal 1, parse('a??').as_json[:max]
    assert_equal inf, parse('a{1,}?').as_json[:max]
    assert_equal 2, parse('a{,2}?').as_json[:max]
    assert_equal 2, parse('a{1,2}?').as_json[:max]
    #    assert_equal 2, parse('a{2}?').as_json[:max]
    #    assert_equal 2, parse('a{2,2}?').as_json[:max]


    assert_equal 1, parse('a+?').as_json[:min]
    assert_equal 0, parse('a*?').as_json[:min]
    assert_equal 0, parse('a??').as_json[:min]
    assert_equal 1, parse('a{1,}?').as_json[:min]
    assert_equal 0, parse('a{,2}?').as_json[:min]
    assert_equal 1, parse('a{1,2}?').as_json[:min]
    #    assert_equal 2, parse('a{2}?').as_json[:min]
    #    assert_equal 2, parse('a{2,2}?').as_json[:min]
  end

  def test_posix_char_class
    assert_equal :ascii, parse('[[:ascii:]]').as_json[:children][0][:posix]
    assert_equal :ascii, parse('[a[:ascii:]]').as_json[:children][1][:posix]
    assert_equal :ascii, parse('[[:ascii:]1]').as_json[:children][0][:posix]
    assert_equal :ascii, parse('[a[:ascii:]1]').as_json[:children][1][:posix]
    assert_equal :digit, parse('[^[:digit:]]').as_json[:children][0][:posix]
    assert_equal true, parse('[^[:digit:]]').as_json[:inversed]
    assert_equal({:range_begin => ?a, :range_end => ?z },
                 parse('[a-z[:digit:]]').as_json[:children][0])
    assert_equal({:posix => :digit},
                 parse('[a-z[:digit:]]').as_json[:children][1])
  end


  def test_bol_and_eol
    assert_equal(:bol, parse('^').as_json.values.first)
    assert_equal(:eol, parse('$').as_json.values.first)

    assert_equal([:bol, :eol], parse('^$').as_json.map {|x| x[:assertion] })
    assert_equal(:ascii,
                 parse('^[[:ascii:]]$').as_json[1][:children][0][:posix])
  end


  def test_alternation
    assert_equal(:alternation, parse('a|b').as_json.keys[0])
  end

end
