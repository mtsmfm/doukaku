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

MAP = Hash.new do |hash, key|
  tracks = (:A..:C).map {|c| [c, [c]] }.to_h

  case key
  when 1
    tracks[:A] << :B
    tracks[:B] << :C
  when 2
    tracks[:A] << :C
    tracks[:C] << :B
  when 3
    tracks[:A] << :C
    tracks[:B] << :A
  when 4..6
    tracks = tracks.keys.map {|k| [k, MAP[key - 3].select {|_, v| v.include?(k) }.keys] }.to_h
  when 7
    tracks[:B] = []
  when 8
    tracks[:A] = []
  when 9
    tracks[:C] = []
  end

  tracks
end


def solve(input)
  input.reverse.each_char.reduce(%i(A B C)) {|ok, c|
    MAP[c.to_i].select {|k, vs| vs.any? {|v| ok.include?(v) } }.keys
  }.join.downcase.presence || ?-
end

TEST_DATA = <<~EOS
/*0*/ test( "1728398", "bc" );
/*1*/ test( "789", "-" );
/*2*/ test( "274", "ac" );
/*3*/ test( "185", "abc" );
/*4*/ test( "396", "ab" );
/*5*/ test( "1278", "abc" );
/*6*/ test( "7659832", "a" );
/*7*/ test( "178", "bc" );
/*8*/ test( "189", "ab" );
/*9*/ test( "197", "a" );
/*10*/ test( "278", "ac" );
/*11*/ test( "289", "bc" );
/*12*/ test( "297", "a" );
/*13*/ test( "378", "ac" );
/*14*/ test( "389", "b" );
/*15*/ test( "397", "ab" );
/*16*/ test( "478", "c" );
/*17*/ test( "489", "bc" );
/*18*/ test( "497", "ab" );
/*19*/ test( "578", "bc" );
/*20*/ test( "589", "b" );
/*21*/ test( "597", "ac" );
/*22*/ test( "678", "c" );
/*23*/ test( "689", "ab" );
/*24*/ test( "697", "ac" );
/*25*/ test( "899", "b" );
/*26*/ test( "7172", "ac" );
/*27*/ test( "54787", "bc" );
/*28*/ test( "83713", "bc" );
/*29*/ test( "149978", "-" );
/*30*/ test( "159735", "abc" );
/*31*/ test( "1449467", "abc" );
/*32*/ test( "9862916", "b" );
/*33*/ test( "96112873", "ab" );
/*34*/ test( "311536789", "-" );
/*35*/ test( "281787212994", "abc" );
/*36*/ test( "697535114542", "ac" );
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
