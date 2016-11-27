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

def solve(input)
  board = input.chars.reduce([[true]], &method(:process))

  number = 0
  board.each.with_index do |row, y|
    row.each.with_index do |col, x|
      unless col
        fill(board, [[x, y]], number)
        number += 1
      end
    end
  end

  number.to_s
end

def fill(board, positions, number)
  positions.each do |x, y|
    board[y][x] = number if fillable?(board, x, y)
  end

  next_pos = positions.flat_map {|x, y| around(x, y) }.select {|x, y| fillable?(board, x, y) }.uniq

  fill(board, next_pos, number) if next_pos.any?
end

def around(x, y)
  [
    [x,     y + 1],
    [x,     y - 1],
    [x + 1, y],
    [x - 1, y]
  ]
end

def fillable?(board, x, y)
  x < board.size && y < board.size && x >= 0 && y >= 0 && board[y][x].nil?
end

def process(board, char)
  new_board = Array.new(board.size * 3) { Array.new(board.size * 3) }

  board.each.with_index do |row, y|
    row.each.with_index do |col, x|
      if col
        t = y * 3
        c = y * 3 + 1
        b = y * 3 + 2

        l = x * 3
        m = x * 3 + 1
        r = x * 3 + 2

        if char == "X"
          new_board[t][m] =
          new_board[c][l] =
          new_board[c][r] =
          new_board[b][m] = true
        else
          new_board[t][l] =
          new_board[t][r] =
          new_board[c][m] =
          new_board[b][l] =
          new_board[b][r] = true
        end
      end
    end
  end

  new_board
end

def print_board(board)
  board.each do |row|
    row.each do |col|
      print(
        case col
        when true
          "□"
        when nil
          "■"
        else
          col
        end
      )
    end

    puts
  end
end

TEST_DATA = <<~EOS
  /*0*/ test("X", "5")
  /*1*/ test("O", "4")
  /*2*/ test("XX", "5")
  /*3*/ test("OX", "10")
  /*4*/ test("XO", "9")
  /*5*/ test("XOO", "17")
  /*6*/ test("OXX", "21")
  /*7*/ test("OXO", "18")
  /*8*/ test("OOOX", "130")
  /*9*/ test("OXXO", "29")
  /*10*/ test("XXOX", "81")
  /*11*/ test("XOXXO", "89")
  /*12*/ test("OOOOX", "630")
  /*13*/ test("OXOOO", "66")
  /*14*/ test("OXOXOX", "2001")
  /*15*/ test("OXOXXO", "417")
  /*16*/ test("OXXOXX", "1601")
  /*17*/ test("XXXOXOO", "345")
  /*18*/ test("OOOOOXO", "3258")
  /*19*/ test("OXXOXXX", "6401")
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

__END__
TEST_DATA = <<~EOS
  X
  O
  XX
  OX
  XO
  XOO
  OXX
  OXO
  OOOX
  OXXO
  XXOX
  XOXXO
  OOOOX
  OXOOO
  OXOXOX
  OXOXXO
  OXXOXX
  XXXOXOO
  OOOOOXO
  OXXOXXX
EOS

TEST_DATA.each_line.with_index do |test, i|
  input = test.chop

  puts %!/*#{i}*/ test("#{input}", "#{solve(input)}")!
end
