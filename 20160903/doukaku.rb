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

class Seg
  class << self
    def convert_str_to_set(str)
      str.to_i(16).to_s(2).chars.reverse.map.with_index.select {|e, i| e == '1' }.map(&:last).to_set
    end
  end

  LIGHTS = %w(3f 06 5b 4f 66 6d 7d 27 7f 6f).map {|s| convert_str_to_set(s) }.map.with_index.to_a
  DARKS = %w(40 79 24 30 19 12 02 58 00 10).map {|s| convert_str_to_set(s) }.map.with_index.to_a

  def initialize(light, dark)
    @light = self.class.convert_str_to_set(light)
    @dark = self.class.convert_str_to_set(dark)
  end

  def candidates
    ls = LIGHTS.select {|e, i| e.superset?(@light) }.map(&:last)
    ds = DARKS.select {|e, i| e.superset?(@dark) }.map(&:last)

    result = (ls & ds)

    if ls.count == 10
      result << nil
    end

    result
  end
end

def solve(input)
  lights, darks = input.split(?,).map {|e| e.split(?:) }
  segs = lights.zip(darks).map.with_index {|(l, d), i| Seg.new(l, d) }
  candidates = segs.map(&:candidates)

  return '-' if candidates.any?(&:empty?)

  binding.pry

  [candidates.map(&:min).join.to_i, candidates.map(&:max).join].join(?,)
end

TEST_DATA = <<~EOS
/*0*/ test( "06:4b:46:64:6d,79:20:10:10:02", "12345,13996" );
/*1*/ test( "41:00,3e:01", "-" );
/*2*/ test( "00:00,79:79", "1,11" );
/*3*/ test( "02:4b:46:64,20:20:10:10", "1234,3399" );
/*4*/ test( "06:2f:3f:27,40:00:00:40", "1000,7987" );
/*5*/ test( "00:3d:2d:26,00:00:00:00", "600,9899" );
/*6*/ test( "40:20:10,00:00:00", "200,998" );
/*7*/ test( "00:00:00,40:20:10", "1,739" );
/*8*/ test( "08:04:02:01,00:00:00:00", "2000,9999" );
/*9*/ test( "00:00:00:00,08:04:02:01", "1,7264" );
/*10*/ test( "08:04:02:01,01:02:04:08", "-" );
/*11*/ test( "04:02:01,02:04:08", "527,627" );
/*12*/ test( "04:02:01:40:10,02:04:08:10:20", "52732,62792" );
/*13*/ test( "00:30:07,00:01:10", "-" );
/*14*/ test( "37,00", "0,8" );
/*15*/ test( "3f,40", "0,0" );
/*16*/ test( "3f:3f,40:40", "-" );
/*17*/ test( "00:3f,40:40", "0,70" );
/*18*/ test( "00:3f,38:00", "0,18" );
/*19*/ test( "18,07", "-" );
/*20*/ test( "08,10", "3,9" );
/*21*/ test( "42,11", "4,4" );
/*22*/ test( "18,05", "-" );
/*23*/ test( "10:00,0b:33", "-" );
/*24*/ test( "14:02,00:30", "61,83" );
/*25*/ test( "00:1a,3d:04", "2,2" );
/*26*/ test( "00:28,38:40", "0,10" );
/*27*/ test( "20:08:12,4f:37:24", "-" );
/*28*/ test( "02:4c:18,00:00:04", "132,992" );
/*29*/ test( "4a:7a:02,10:00:30", "381,983" );
/*30*/ test( "00:00:06,0b:11:08", "1,47" );
/*31*/ test( "04:20:2c:14,39:08:50:09", "-" );
/*32*/ test( "02:06:02:02,00:31:18:11", "1111,9174" );
/*33*/ test( "00:04:48:50,03:02:20:02", "526,636" );
/*34*/ test( "00:58:42:40,00:20:08:12", "245,9245" );
/*35*/ test( "08:08:60:00:32,76:67:02:16:04", "-" );
/*36*/ test( "00:00:00:08:02,06:1a:3b:20:11", "21,34" );
/*37*/ test( "08:58:12:06:12,10:20:20:00:04", "32202,92292" );
/*38*/ test( "00:10:74:4e:10,10:04:02:00:24", "2632,92692" );
/*39*/ test( "44:76:0a:00:0c:44,39:08:11:09:02:11", "-" );
/*40*/ test( "00:00:44:0a:04:00,79:06:02:04:79:28", "5211,6211" );
/*41*/ test( "30:02:02:2c:0e:02,00:08:04:02:20:01", "612531,872634" );
/*42*/ test( "00:00:04:10:00:60,25:19:01:02:24:00", "1624,44629" );
/*43*/ test( "04:18:54:38:00:14:70,10:65:09:01:6c:00:0d", "-" );
/*44*/ test( "18:04:26:20:04:24:1a,02:21:50:48:02:08:00", "6177540,6177678" );
/*45*/ test( "00:08:34:00:00:64:06,18:24:02:00:61:08:61", "260141,7269141" );
/*46*/ test( "00:02:0a:04:4a:00:20,18:21:24:02:04:60:19", "125214,7126214" );
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
