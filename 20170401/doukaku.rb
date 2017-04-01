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

def normalize(board)
  cols = []
  board.each.with_index do |row, y|
    row.each.with_index do |col, x|
      cols << [x, y] if col.present?
    end
  end

  min_x = cols.map(&:first).min
  min_y = cols.map(&:last).min

  cols.map! {|x, y| [x - min_x, y - min_y] }
end

B = [
<<~S,
X
 X X
  X
S
<<~S,
 X
X X
   X
S
<<~S,
  X
 X
X X
S
<<~S,
X X
 X
X
S
<<~S,
   X
X X X
S
<<~S,
X X X
 X
S
].map {|s| s.each_line.map {|l| l.chomp.chars } }.map {|xs| normalize(xs) }

D = [
<<~S,
   X
X X
 X
S
<<~S,
  X
 X X
X
S
<<~S,
X
 X
X X
S
<<~S,
X X
 X
  X
S
<<~S,
X X X
   X
S
<<~S,
 X
X X X
S
].map {|s| s.each_line.map {|l| l.chomp.chars } }.map {|xs| normalize(xs) }

I = [
<<~S,
X X X X
S
<<~S,
X
 X
  X
   X
S
<<~S,
   X
  X
 X
X
S
].map {|s| s.each_line.map {|l| l.chomp.chars } }.map {|xs| normalize(xs) }

def b?(board)
  normalized_board = normalize(board)

  B.any? {|b| normalize(board) == b }
end

def d?(board)
  normalized_board = normalize(board)

  D.any? {|d| normalize(board) == d }
end

def i?(board)
  normalized_board = normalize(board)

  I.any? {|i| normalize(board) == i }
end

def solve(input)
  board = Array.new(5) { Array.new(10) }

  input.chars.each do |c|
    case c
    when ?a..?e
      board[0][(c.ord - ?a.ord) * 2] = c
    when ?f..?i
      board[1][(c.ord - ?f.ord) * 2 + 1] = c
    when ?j..?n
      board[2][(c.ord - ?j.ord) * 2] = c
    when ?o..?r
      board[3][(c.ord - ?o.ord) * 2 + 1] = c
    when ?s..?w
      board[4][(c.ord - ?s.ord) * 2] = c
    end
  end

  if b?(board)
    ?B
  elsif d?(board)
    ?D
  elsif i?(board)
    ?I
  else
    ?-
  end
end

TEST_DATA = <<~EOS
/*0*/ test( "glmq", "B" );
/*1*/ test( "fhoq", "-" );
/*2*/ test( "lmpr", "-" );
/*3*/ test( "glmp", "-" );
/*4*/ test( "dhkl", "-" );
/*5*/ test( "glpq", "D" );
/*6*/ test( "hlmq", "-" );
/*7*/ test( "eimq", "I" );
/*8*/ test( "cglp", "-" );
/*9*/ test( "chlq", "-" );
/*10*/ test( "glqr", "-" );
/*11*/ test( "cdef", "-" );
/*12*/ test( "hijk", "-" );
/*13*/ test( "kpqu", "B" );
/*14*/ test( "hklm", "B" );
/*15*/ test( "mqrw", "B" );
/*16*/ test( "nrvw", "B" );
/*17*/ test( "abfj", "B" );
/*18*/ test( "abcf", "B" );
/*19*/ test( "mrvw", "D" );
/*20*/ test( "ptuv", "D" );
/*21*/ test( "lmnr", "D" );
/*22*/ test( "hklp", "D" );
/*23*/ test( "himr", "D" );
/*24*/ test( "dhil", "D" );
/*25*/ test( "hlpt", "I" );
/*26*/ test( "stuv", "I" );
/*27*/ test( "bglq", "I" );
/*28*/ test( "glmn", "-" );
/*29*/ test( "fghm", "-" );
/*30*/ test( "cdgk", "-" );
/*31*/ test( "lpst", "-" );
/*32*/ test( "imrw", "-" );
/*33*/ test( "dinr", "-" );
/*34*/ test( "cdin", "-" );
/*35*/ test( "eghi", "-" );
/*36*/ test( "cdeg", "-" );
/*37*/ test( "bgko", "-" );
/*38*/ test( "eimr", "-" );
/*39*/ test( "jotu", "-" );
/*40*/ test( "kotu", "-" );
/*41*/ test( "lqtu", "-" );
/*42*/ test( "cdim", "-" );
/*43*/ test( "klot", "-" );
/*44*/ test( "kloq", "-" );
/*45*/ test( "kmpq", "-" );
/*46*/ test( "qrvw", "-" );
/*47*/ test( "mnqr", "-" );
/*48*/ test( "kopt", "-" );
/*49*/ test( "mnpq", "-" );
/*50*/ test( "bfko", "-" );
/*51*/ test( "chin", "-" );
/*52*/ test( "hmnq", "-" );
/*53*/ test( "nqrw", "-" );
/*54*/ test( "bchi", "-" );
/*55*/ test( "inrw", "-" );
/*56*/ test( "cfgj", "-" );
/*57*/ test( "jnpv", "-" );
/*58*/ test( "flmp", "-" );
/*59*/ test( "adpw", "-" );
/*60*/ test( "eilr", "-" );
/*61*/ test( "bejv", "-" );
/*62*/ test( "enot", "-" );
/*63*/ test( "fghq", "-" );
/*64*/ test( "cjms", "-" );
/*65*/ test( "elov", "-" );
/*66*/ test( "chlm", "D" );
/*67*/ test( "acop", "-" );
/*68*/ test( "finr", "-" );
/*69*/ test( "qstu", "-" );
/*70*/ test( "abdq", "-" );
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
