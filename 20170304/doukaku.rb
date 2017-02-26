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

class Tetromino
  module I
    def tiles
      [
        [0, 3],
        [0, 2],
        [0, 1],
        [0, 0],
      ]
    end
  end

  module S
    def tiles
      [
                [1, 1], [2, 1],
        [0, 0], [1, 0],
      ]
    end
  end

  module L
    def tiles
      [
        [0, 2],
        [0, 1],
        [0, 0], [1, 0],
      ]
    end
  end

  module O
    def tiles
      [
        [0, 1], [1, 1],
        [0, 0], [1, 0],
      ]
    end
  end

  module T
    def tiles
      [
        [0, 1], [1, 1], [2, 1],
                [1, 0],
      ]
    end
  end

  attr_reader :pos

  def initialize(pos, type)
    @pos = pos.to_i
    @type = type

    extend(self.class.const_get(type))
  end
end

class Board
  def initialize(width: 5)
    @width = 5
    @board = []
  end

  def add(omino)
    y = (0..height).find {|y| omino.tiles.all? {|t_x, t_y| @board.dig(t_y + y, t_x + omino.pos).nil? } }

    omino.tiles.each do |t_x, t_y|
      new_x = t_x + omino.pos
      new_y = t_y + y

      append_row until height > new_y

      @board[new_y][new_x] = true
    end
  end

  def height
    @board.size
  end

  private

  def append_row
    @board << [nil] * @width
  end
end

def solve(input)
  ominos = input.scan(/(\d+)(\D+)/).map {|pos, type| Tetromino.new(pos, type) }

  board = Board.new
  ominos.each do |omino|
    board.add(omino)
  end
  board.height.to_s
end

TEST_DATA = <<~EOS
/*0*/ test( "0I0I", "8" );
/*1*/ test( "0I1I2I3I4I", "4" );
/*2*/ test( "0S1I", "6" );
/*3*/ test( "0S0I", "5" );
/*4*/ test( "3S0T2O3I", "8" );
/*5*/ test( "1O3O0I", "4" );
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
