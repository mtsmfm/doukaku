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

class Board
  attr_reader :width, :height, :board
  delegate :inspect, :map, :[], :[]=, :flatten, to: :board
  def initialize(width, height)
    @width = width
    @height = height
    @board = Array.new(height) { Array.new(width) { ?. } }
  end

  def count(target)
    board[0...-1].each.with_index.sum {|row, y|
      row.each.with_index.count {|c, x|
        [board[y][x], board[y][x+1], board[y+1][x], board[y+1][x+1]].uniq == [target]
      }
    }
  end

  def con
    b = dup
    board.each.with_index do |row, y|
      row.each.with_index do |c, x|
        b.connect!(x, y) unless c == ?.
      end
    end

    b
  end

  def connect(x, y)
    dup.connect!(x, y)
  end

  def connect!(x, y)
    target = board[y][x]

    xs = ((x + 1)...width).map {|_x| board[y][_x] }
    if xs.include?(target)
      another_index = xs.find_index {|e| !e.in?([?., target])}
      last_index = (another_index ? xs.take(another_index) : xs).rindex(target)

      (1..last_index).each {|i|
        board[y][x + i] = target
      } if last_index
    end

    ys = ((y + 1)...height).map {|_y| board[_y][x] }
    if ys.include?(target)
      another_index = ys.find_index {|e| !e.in?([?., target])}
      last_index = (another_index ? ys.take(another_index) : ys).rindex(target)

      (1..last_index).each {|i|
        board[y + i][x] = target
      } if last_index
    end

    self
  end

  def inspect
    "\n" + board.map {|row| row.join(?|) }.join("\n")
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end
end

def parse(input)
  w, b = input.split(?,).map {|str| str.scan(/(\w+?)(\d+?)/).map {|c, d| [c.ord - ?a.ord, d.to_i - 1] } }
  w ||= [[]]
  b ||= [[]]
  [w, b]
end

def solve(input)
  w, b = parse(input)

  width  = [w.max_by(&:first).max || 0, b.max_by(&:first).max || 0].max + 1
  height = [w.max_by(&:last).max || 0, b.max_by(&:last).max || 0].max + 1
  board = Board.new(width, height)

  w.each do |x, y|
    board[y][x] = 'w'
  end if w.flatten.any?

  b.each do |x, y|
    board[y][x] = 'b'
  end if b.flatten.any?

  board = board.con

  [board.count(?w), board.count(?b)].join(?,)
end

TEST_DATA = <<~EOS
  /*0*/ test("b1d1b2d2e2f2b5d5e5f5b6d6,b3d3b4d4", "7,2")
  /*1*/ test("b2c2e2f2b3c3e3f3b5c5e5f5,d4", "8,0")
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
