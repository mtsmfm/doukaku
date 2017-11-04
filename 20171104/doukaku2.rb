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

def candidates(lines_list)
  p lines_list
  lines_list.reject! {|lines| invalid?(lines) }

  return [] if lines_list.size == 0
  return lines_list if lines_list.all? {|lines| lines.all? {|cards| cards.all? {|c| c.size == 1 } } }

  result = []

  lines_list.each do |lines|
    lines.each.with_index do |cards, i|
      cards.map.with_index do |card, j|
        next_list = lines_list.map {|lines| lines.map {|cards| cards.map(&:dup) }}

        next card if card.size == 1

        card.shift

        remove_invalid_candidate(lines)

        return
      end
    end
  end

  candidates(next_list)
end

def invalid?(lines)
  lines.any? {|cards| cards.any? {|card| card.size == 0 } }
end

def remove_invalid_candidate(lines)
  return if invalid?(lines)

  fixed = lines.flat_map {|cards| cards.select {|card| card.size == 1 }.flatten }.group_by(&:itself).transform_values(&:count)

  if fixed.values.any? {|k, v| v.count > lines.size }
    lines.each {|cards| cards.each(&:clear) }

    return
  end

  remove_candidates = {}

  lines.each.with_index do |cards, i|
    cards.each.with_index do |card, j|
      next if card.size == 1

      card.each do |x|
        remove_candidates[[i, j]] ||= Set.new
        remove_candidates[[i, j]] << x if fixed[x] == lines.size
        remove_candidates[[i, j]] << x if x > cards[j + 1]&.max
        if j > 0
          if x < cards[j - 1]&.min || cards[0...j].count {|c| c.include?(x) } + fixed[x].to_i >= lines.count
            remove_candidates[[i, j]] << x
          end
        end

        cards[0..j]
      end

      if cards.count(card) > card.size && lines.size
        remove_candidates[[i, j]] << x
      end
    end
  end

  return if remove_candidates.values.all?(&:empty?)

  remove_candidates.each do |(i, j), vs|
    vs.each do |v|
      lines[i][j].delete(v)
    end
  end

  remove_invalid_candidate(lines)
end

def solve(input)
  lines = input.split(?,).map(&:chars)
  numbers = (1..lines.first.size).to_a

  lines = lines.map do |back_cards|
    back_cards.map do |back|
      if back == ?o
        numbers.select(&:odd?)
      else
        numbers.select(&:even?)
      end
    end
  end

  remove_invalid_candidate(lines)

  candidates([lines]).uniq.map {|xs| xs.flatten.join(?,) }.join(?|)
end

TEST_DATA = <<~EOS
/*0*/ test("ooooo,xxxxo", "1,1,3,3,5,2,2,4,4,5");
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
