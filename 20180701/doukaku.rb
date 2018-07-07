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

def calc(n, m)
  ((n ** 2) + (m ** 2)) * 2
end

def find_positions_list(x, y, p_x, p_y, n, m)
  positions_list = [
    [n, m],
    [n, -m],
    [-n, m],
    [-n, -m],
    [m, n],
    [m, -n],
    [-m, n],
    [-m, -n],
  ].uniq.map do |nn, mm|
    a = [p_x, p_y]
    b = [p_x + nn, p_y - mm]
    c = [p_x + nn + mm, p_y - mm + nn]
    d = [p_x + mm - nn, p_y + nn + mm]

    [a, b, c, d]
  end.select do |positions|
    positions.all? {|xx, yy| (0...x).include?(xx) && (0...y).include?(yy) }
  end

  positions_list
end

def _solve(input)
  x, y, p_x, p_y = input.scan(/\d+/).map(&:to_i)

  variations = [*0...x].product([*0...y])

  variations.select {|n, m| calc(n, m) > 0 }.group_by {|n, m| calc(n, m) }.to_a.sort_by {|size, *| -size }
    .lazy.flat_map {|_, xs| xs.map {|n, m| find_positions_list(x, y, p_x, p_y, n, m) }.uniq }.select(&:any?).tap {|xs| binding.pry if $DEBUG }.first
end

def _to_s(result)
  result&.count == 1 ? result.first.from(1).map {|p| "(#{p.join(?,)})" }.join(",") : ?-
end

def solve(input)
  _to_s(_solve(input))
end

TEST_DATA = <<~EOS
/*0*/ test("4,7,(0,3)", "(0,0),(3,0),(3,6)");
/*1*/ test("4,6,(3,3)", "(2,5),(0,4),(2,0)");
/*2*/ test("1,1,(0,0)", "-");
/*3*/ test("2,2,(0,0)", "-");
/*4*/ test("2,3,(0,0)", "-");
/*5*/ test("2,3,(0,1)", "(0,0),(1,0),(1,2)");
/*6*/ test("2,3,(1,1)", "(1,2),(0,2),(0,0)");
/*7*/ test("2,3,(1,2)", "-");
/*8*/ test("3,4,(1,2)", "-");
/*9*/ test("4,3,(2,2)", "(1,2),(1,1),(3,1)");
/*10*/ test("7,7,(2,5)", "(0,3),(2,1),(6,5)");
/*11*/ test("8,7,(1,1)", "(3,0),(4,2),(0,4)");
/*12*/ test("9,7,(3,6)", "(0,4),(2,1),(8,5)");
/*13*/ test("10,7,(6,6)", "(3,6),(3,3),(9,3)");
/*14*/ test("10,11,(4,2)", "(8,1),(9,5),(1,7)");
/*15*/ test("10,12,(0,3)", "(3,0),(6,3),(0,9)");
/*16*/ test("10,13,(0,0)", "-");
/*17*/ test("10,14,(4,3)", "(8,2),(9,6),(1,8)");
/*18*/ test("15,15,(2,1)", "(5,0),(6,3),(0,5)");
/*19*/ test("16,17,(14,13)", "(10,16),(7,12),(15,6)");
/*20*/ test("19,7,(18,0)", "-");
/*21*/ test("20,7,(1,4)", "(0,1),(3,0),(5,6)");
/*22*/ test("25,11,(15,1)", "(24,1),(24,10),(6,10)");
/*23*/ test("26,12,(12,8)", "(4,8),(4,0),(20,0)");
/*24*/ test("27,13,(14,2)", "(24,2),(24,12),(4,12)");
/*25*/ test("28,14,(6,6)", "-");
/*26*/ test("30,30,(25,17)", "(20,29),(8,24),(18,0)");
/*27*/ test("35,36,(32,3)", "(34,8),(29,10),(25,0)");
/*28*/ test("150,130,(50,113)", "(8,56),(65,14),(149,128)");
/*29*/ test("180,120,(120,18)", "-");
/*30*/ test("200,200,(24,134)", "(0,45),(89,21),(137,199)");
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
