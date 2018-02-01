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
  dead_members_indexes = []
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
  dead_members_indexes = []
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
/*1*/ test("31[2]/6", "000010");
/*2*/ test("32[1]/6", "000001");
/*3*/ test("[2][2]2/6", "100010");
/*4*/ test("1[3][2]/6", "010010");
/*5*/ test("2[2]2/6", "001000");
/*6*/ test("2[1]23/7", "0010000");
/*7*/ test("13[1]3/7", "0000100");
/*8*/ test("[4]2[1]2/7", "1010000");
/*9*/ test("3[1][2]2[2]/8", "00011010");
/*10*/ test("4[4]21[1]/8", "00001001");
/*11*/ test("[2][2]124/8", "11000000");
/*12*/ test("[3]4[2][1][3]3/9", "100010110");
/*13*/ test("[2][1]43[2]3/9", "101010000");
/*14*/ test("3[3][1]4[1]3/9", "010100100");
/*15*/ test("[3][5][3]554[4]/10", "1100001100");
/*16*/ test("[3]2[3][5][3]45/10", "1110010000");
/*17*/ test("53[1]4[1]2[4]/10", "0010100010");
/*18*/ test("2[3][2]5[4]54[1]/11", "00110010100");
/*19*/ test("[3][5]554[2]25/11", "10000010010");
/*20*/ test("[1]5[5]413[5]2/11", "10100100000");
/*21*/ test("[1]33[3]52[5][4]2/12", "110000101000");
/*22*/ test("4[4]3[1][3]4[1]4[3]/12", "010011010100");
/*23*/ test("[3]2[1][2]14[2]54/12", "101100000010");
/*24*/ test("[2][6]45[3][2]42[6]2/13", "1001100011000");
/*25*/ test("[1]2[3][3]6[3][1]56[4]/13", "1010001010101");
/*26*/ test("3[4]213[6]1[1]5[6]/13", "0011000001100");
/*27*/ test("6[3]8[8]8[6]4[4][2][8][7][9]/15", "000101111011001");
/*28*/ test("[4]6[5]15[2]6[5]343[2]/15", "100100100000110");
/*29*/ test("66[6]2[9]6[6][9]5[6]11/15", "001001010000101");
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
