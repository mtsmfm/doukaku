require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'minitest', require: 'minitest/autorun'
  gem 'minitest-reporters'

  gem 'awesome_print'
  gem 'tapp'

  gem 'pry'
  gem 'pry-rescue', require: 'pry-rescue/minitest'
  gem 'pry-stack_explorer'
end

class Node
  attr_reader :base, :children, :ancestors

  include Enumerable

  def initialize(base, ancestors=[])
    @base = base
    @ancestors = [self] + ancestors
    @children = children_for(base).map do |n|
      Node.new(n, @ancestors)
    end
  end

  def each(&block)
    block.call(self)

    children.each do |leaf|
      leaf.each(&block)
    end
  end

  def distance(a, b)
    as = select {|tree| tree.base == a }
    bs = select {|tree| tree.base == b }

    as.product(bs).map {|_a, _b|
      common_ancestor = (_a.ancestors & _b.ancestors).first
      _a.ancestors.index(common_ancestor) + _b.ancestors.index(common_ancestor)
    }.min
  end

  private

  def children_for(base)
    return [] if base <= 3

    (2...base).select {|n| base % n == 0 }.map {|n| n + 1 }
  end
end

def solve(input)
  base, a, b = input.scan(/\d+/).map(&:to_i)
  Node.new(base).distance(a, b).to_s
end

TEST_DATA = <<~EOS
/*0*/ test( "50:6,3", "1" );
/*1*/ test( "98:5,11", "4" );
/*2*/ test( "1000:33,20", "7" );
/*3*/ test( "514:9,18", "8" );
/*4*/ test( "961:5,4", "3" );
/*5*/ test( "1369:1369,3", "2" );
/*6*/ test( "258:16,12", "5" );
/*7*/ test( "235:13,3", "2" );
/*8*/ test( "1096:19,17", "8" );
/*9*/ test( "847:7,17", "6" );
/*10*/ test( "1932:3,5", "2" );
/*11*/ test( "2491:4,8", "3" );
/*12*/ test( "840:421,36", "2" );
/*13*/ test( "1430:37,111", "3" );
/*14*/ test( "496:17,9", "2" );
/*15*/ test( "891:6,10", "1" );
/*16*/ test( "1560:196,21", "2" );
/*17*/ test( "516:20,12", "5" );
/*18*/ test( "696:30,59", "2" );
/*19*/ test( "1760:5,441", "2" );
/*20*/ test( "1736:11,26", "5" );
/*21*/ test( "1518:17,34", "4" );
/*22*/ test( "806:63,16", "5" );
/*23*/ test( "1920:3,97", "2" );
/*24*/ test( "1150:13,22", "4" );
/*25*/ test( "920:116,5", "1" );
/*26*/ test( "2016:7,337", "2" );
/*27*/ test( "408:9,25", "2" );
/*28*/ test( "735:36,8", "2" );
/*29*/ test( "470:5,31", "2" );
/*30*/ test( "2100:12,351", "3" );
/*31*/ test( "870:36,10", "1" );
/*32*/ test( "1512:253,13", "2" );
/*33*/ test( "697:12,15", "3" );
/*34*/ test( "1224:5,14", "2" );
/*35*/ test( "986:125,17", "3" );
/*36*/ test( "864:12,13", "3" );
/*37*/ test( "500:21,51", "2" );
/*38*/ test( "819:33,21", "4" );
/*39*/ test( "594:55,3", "2" );
/*40*/ test( "638:17,24", "3" );
EOS

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)

describe 'Doukaku' do
  TEST_DATA.each_line do |test|
    number, input, expected = test.scan(/(\d+).*"(.*)", "(.*)"/)[0]

    it "##{number}" do
      assert_equal expected, solve(input)
    end
  end
end
