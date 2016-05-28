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

MAP = {
  1 => %w(A B),
  2 => %w(B C),
  3 => %w(C D),
  4 => %w(D E),
  5 => %w(E F),
  6 => %w(F G),
  7 => %w(G H),
  8 => %w(H A)
}

def solve(input)
  lines, start_rock = input.split(?:)
  lines = lines.chars.map(&:to_i)

  ng_indexes = []

  rock = start_rock
  lines.each.with_index do |l, i|
    if MAP[l].include?(rock)
      rock = (MAP[l] - [rock]).first
      ng_indexes << i
    end
  end

  dead = []

  puts "start_rock: %s, rock: %s" % [start_rock, rock]

  (?A..?H).each do |man|
    puts man

    pos = man

    lines.each.with_index.to_a.reverse.each do |l, i|
      print pos

      if MAP[l].include?(pos)
        if i.in?(ng_indexes)
          dead << man
          break
        else
          pos = (MAP[l] - [pos]).first
        end
      end
    end

    dead << man if dead.exclude?(man) && (man == rock || pos == start_rock)

    p dead
  end

  ((?A..?H).to_a - dead).join
end

TEST_DATA = <<~EOS
  test("1228:A", "ADEFG")
EOS

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)

describe 'Doukaku' do
  TEST_DATA.each_line do |test|
    input, expected = test.scan(/"(.*)", "(.*)"/)[0]

    it input do
      assert_equal expected, solve(input)
    end
  end
end
