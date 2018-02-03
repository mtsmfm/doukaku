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
  raw_members, max_num = input.split(?/, 2)
  dead_members_indexes = Set.new
  members = raw_members.scan(/\[?\d\]?/).map.with_index do |m, i|
    if m.start_with?(?[)
      dead_members_indexes << i
      m.tr('[]', '')
    else
      m
    end
  end.map(&:to_i)

  max_num = max_num.to_i
  bullet_num = dead_members_indexes.size
  (0...max_num).to_a.combination(bullet_num).lazy.map do |bullets|
    gun = Array.new(max_num, false)
    bullets.each do |b|
      gun[b] = true
    end
    gun
  end.select {|gun| simulate(gun, members) == dead_members_indexes }.map do |gun|
    gun.map {|x| x ? 1 : 0 }.join
  end.force.join(?|)
end

def simulate(gun, members)
  gun = gun.dup
  dead_members_indexes = Set.new
  current_gun_index = 0
  try_history = Hash.new do |hash, key|
    hash[key] = []
  end

  while gun.any?
    members.each.with_index do |m, i|
      next if dead_members_indexes.include?(i)

      if gun[current_gun_index]
        gun[current_gun_index] = false
        dead_members_indexes << i
        try_history.clear
      else
        return dead_members_indexes if try_history[i].include?(current_gun_index)

        try_history[i] << current_gun_index
        current_gun_index = (current_gun_index + m) % gun.size
      end
    end
  end

  dead_members_indexes
end

TEST_DATA = <<~EOS
/*0*/ test("3[2]3/6", "000100");
/*1*/ test("21[3]/6", "000100");
/*2*/ test("12[3]/6", "000100");
/*3*/ test("3[2]1/6", "000100");
/*4*/ test("3[2]3/6", "000100");
/*5*/ test("1[1]3/6", "010000");
/*6*/ test("[3]4[4]3/7", "1000100");
/*7*/ test("4[4]24/7", "0000100");
/*8*/ test("[4]41[1]/7", "1000010");
/*9*/ test("1[1]33[1]/8", "01000001");
/*10*/ test("[1]12[4][3]/8", "10100001");
/*11*/ test("2[2][1]12/8", "01001000");
/*12*/ test("1[2][2][1]34/9", "011100000");
/*13*/ test("[4]1141[2]/9", "100000010");
/*14*/ test("[3]33[3][2]2/9", "100000110");
/*15*/ test("[5]1[3]44[2][3]/10", "0100101001");
/*16*/ test("3[1][2]23[3][1]/10", "0110110000");
/*17*/ test("33[5]12[5][2]/10", "0000010011");
/*18*/ test("13[3]1[4][4][4][1]/11", "00101100110");
/*19*/ test("[5]3[2]35[1]1[4]/11", "10001010001");
/*20*/ test("4[1]4[5]342[5]/11", "00001010100");
/*21*/ test("[5][4]55[2][2][4]33/12", "001111100000");
/*22*/ test("3[2]415[1][4][4]3/12", "010101000100");
/*23*/ test("3[2][4][2][4]4[5]4[1]/12", "011001110010");
/*24*/ test("3555[6]33[6]4[1]/13", "0010010000010");
/*25*/ test("4[1]32[6]3[3]4[3]4/13", "0001100001001");
/*26*/ test("2[2]14[3][1][6][4]63/13", "0010011001010");
/*27*/ test("2[9][9][9]8[2]3[4][8]2[1]8/15", "011010100001110");
/*28*/ test("[1][2][6]64[1][3]68[3][8]8/15", "111001000011010");
/*29*/ test("[7][6][5]54[5]8[5]53[8]1/15", "010001110010001");
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
