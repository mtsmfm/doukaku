require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'activesupport', require: 'active_support/all'

  gem 'minitest', require: 'minitest/autorun'
  gem 'minitest-reporters'

  gem 'awesome_print'
  gem 'tapp'

  gem 'pry'
  gem 'pry-rescue', require: 'pry-rescue/minitest'
  gem 'pry-stack_explorer'
end

WALL = %w(
  12
  28
  4A
  67
  AB
  7D
  8E
  AG
  BH
  DE
  EF
  GH
  DJ
  FL
  IJ
  MN
  KQ
  LR
  OP
  RS
  OU
  QW
  TZ
  WX
  XY
).to_set

class Map
  def initialize(start, goal, map = Array.new(36), current = Point.from_char(start))
    @start = start
    @goal = goal
    @map = map
    @current = current
  end

  def movable_points
    [
      Point.new(@current.x - 1, @current.y),
      Point.new(@current.x + 1, @current.y),
      Point.new(@current.x, @current.y - 1),
      Point.new(@current.x, @current.y + 1)
    ].select do |point|
      (0..5).include?(point.x) && (0..5).include?(point.y) &&
        !marked?(point) && !(WALL.include?(@current.to_s + point.to_s) || WALL.include?(point.to_s + @current.to_s))
    end
  end

  def goal?
    @current.to_s == @goal
  end

  def marked?(point)
    !!@map[index(point)]
  end

  def index(point)
    point.y * 6 + point.x
  end

  def dup
    Map.new(@start, @goal, @map.dup, @current.dup)
  end

  def go(point)
    dup.tap do |new_map|
      new_map.go!(point)
    end
  end

  def go!(point)
    @map[index(point)] = true
    @current = point
  end

  def route_length
    @map.count(true)
  end
end

Point = Struct.new(:x, :y)
def Point.from_char(char)
  new(*[*0..9, *?A..?Z].map(&:to_s).index(char).divmod(6).reverse)
end

class Point
  def to_s
    [*0..9, *?A..?Z].map(&:to_s)[x + y * 6]
  end
end

def find_all(map)
  return map if map.goal?
  return if map.movable_points.empty?

  map.movable_points.flat_map do |point|
    find_all(map.go(point))
  end.compact
end

def solve(input)
  map = Map.new(*input.chars)
  find_all(map).min_by(&:route_length).route_length.to_s
end

TEST_DATA = <<~EOS
/*0*/ test( "DE", "13" );
/*1*/ test( "EK", "1" );
/*2*/ test( "01", "1" );
/*3*/ test( "LG", "2" );
/*4*/ test( "A1", "4" );
/*5*/ test( "GJ", "4" );
/*6*/ test( "FK", "4" );
/*7*/ test( "LV", "4" );
/*8*/ test( "27", "4" );
/*9*/ test( "0O", "4" );
/*10*/ test( "G1", "5" );
/*11*/ test( "ZH", "5" );
/*12*/ test( "AB", "5" );
/*13*/ test( "KX", "5" );
/*14*/ test( "1G", "5" );
/*15*/ test( "WX", "5" );
/*16*/ test( "3L", "5" );
/*17*/ test( "9Y", "5" );
/*18*/ test( "EX", "6" );
/*19*/ test( "BG", "6" );
/*20*/ test( "7K", "7" );
/*21*/ test( "E3", "7" );
/*22*/ test( "SW", "7" );
/*23*/ test( "BM", "7" );
/*24*/ test( "3C", "7" );
/*25*/ test( "H9", "7" );
/*26*/ test( "J3", "7" );
/*27*/ test( "GX", "8" );
/*28*/ test( "2Z", "8" );
/*29*/ test( "8H", "8" );
/*30*/ test( "Z7", "8" );
/*31*/ test( "0B", "8" );
/*32*/ test( "U9", "9" );
/*33*/ test( "Z0", "10" );
/*34*/ test( "0N", "10" );
/*35*/ test( "U8", "10" );
/*36*/ test( "XZ", "10" );
/*37*/ test( "H0", "11" );
/*38*/ test( "CH", "13" );
/*39*/ test( "WB", "13" );
/*40*/ test( "0R", "13" );
/*41*/ test( "DZ", "13" );
/*42*/ test( "NI", "13" );
/*43*/ test( "QC", "14" );
/*44*/ test( "6U", "14" );
/*45*/ test( "PO", "15" );
/*46*/ test( "RI", "16" );
/*47*/ test( "UO", "17" );
/*48*/ test( "WO", "17" );
/*49*/ test( "OX", "18" );
EOS

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)

# docker-compose run --rm -w /app/YYYYmmdd bundle exec ruby doukaku.rb -n /#1$/
describe 'Doukaku' do
  def self.test_order; :sorted; end

  TEST_DATA.each_line do |test|
    number, input, expected = test.scan(/(\d+).*"(.*)", "(.*)"/)[0]

    it "##{number}" do
      assert_equal expected, solve(input)
    end
  end
end
