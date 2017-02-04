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

def puts(*)
  super if $DEBUG
end

class Pokemon
  attr_reader :lvl, :type
  attr_accessor :hp

  def initialize(str)
    @lvl, @type = str.chars
    @lvl = @lvl.to_i
    @hp = @lvl
  end

  def battle(other_poke)
    if lvl == other_poke.lvl
      other_poke.hp -= damage(type, other_poke.type)
      self.hp       -= damage(other_poke.type, type)
      return
    end

    if lvl > other_poke.lvl
      first  = self
      second = other_poke
    elsif lvl < other_poke.lvl
      first  = other_poke
      second = self
    end

    second.hp -= damage(first.type, second.type)
    if second.live?
      first.hp -= damage(second.type, first.type)
    end
  end

  def live?
    hp.positive?
  end

  def inspect
    "lvl: #{lvl}, type: #{type}, hp: #{hp}"
  end

  def to_s
    inspect
  end

  private

  def damage(offence, defence)
    return 2 if offence == defence

    case [offence, defence]
    when %w(R G),%w(G B),%w(B R)
      4
    else
      1
    end
  end
end

class Player
  attr_reader :pokemons, :id

  def initialize(pokemons:, id:)
    @id = id
    @pokemons = pokemons.map {|p| Pokemon.new(p) }
  end

  def heal
    pokemons.each do |p|
      p.hp = p.lvl
    end
  end

  def win?(other_player)
    heal
    other_player.heal

    puts "#{id} vs #{other_player.id}"
    puts ?- * 10

    other_player.pokemons.each do |other_poke|
      pokemons.each do |poke|
        while poke.live? && other_poke.live?
          puts "#{poke} vs #{other_poke}"
          poke.battle(other_poke)
          puts "result: #{poke} vs #{other_poke}"
        end
      end
    end

    pokemons.any?(&:live?)
  end
end

def solve(input)
  players = input.split(?,).map.with_index(1) {|pokemons, i|
    Player.new(pokemons: pokemons.scan(/\d./), id: i)
  }

  players.sort_by.with_index do |player, i|
    [players.without(player).count {|p| !player.win?(p) }, i]
  end.map(&:id).join(?,)
end

TEST_DATA = <<~EOS
/*0*/ test("9B,3R2G,1R2B3G", "1,3,2")
/*1*/ test("1G", "1")
/*2*/ test("1G,1R,1B", "1,2,3")
/*3*/ test("8B,3R2G,1R2B3G", "3,1,2")
/*4*/ test("6G,9R7B7B", "2,1")
/*5*/ test("5B1B,1G1B2R6G,7B6G4B6B", "3,2,1")
/*6*/ test("7R,2R9G,6R4B1G6R,5G1G6G", "3,1,2,4")
/*7*/ test("2B9G8B3R,4R3G,2B,8B", "1,2,4,3")
/*8*/ test("1B,5G1R1B4R,5R,8B9B4G,7G5R8G", "5,4,3,2,1")
/*9*/ test("9G5B,6B6R1R5G,7G6G,8B5R,5G7G,2G5B7B", "2,1,3,4,5,6")
/*10*/ test("5B,1B8R2B,8G6R4B,4B1G6R8G,3B6G6G5R,7B", "3,4,5,6,1,2")
/*11*/ test("2G2G7G9B,6G5G5R,2G,4G,5R,3G8R,6G9R", "1,7,6,2,5,4,3")
/*12*/ test("6G7B4R6B,9R4G,6G5B5G3B,6R7G,9B,7G7B8R,5G8G2R,6B8G7B1B", "8,1,6,2,3,4,7,5")
/*13*/ test("9B8B2G4B,2B1R,7R6G8R,4R,1G7B7R,4B3B4R,4B3R2R4G,4G9R9R", "1,3,8,5,6,7,2,4")
/*14*/ test("5G,3G,9G7G8B,7B,8G6B1B5G,1G3B,5G8R,6G,7B", "3,5,7,8,1,2,4,9,6")
/*15*/ test("5B1R5B,6R,7R7R,8B1B,6R1G,7B3R2R,4R3B,6G1R8G,6B4R4R2B,9G5B", "10,1,4,6,9,3,8,5,7,2")
/*16*/ test("7R4G1G6R,9B3G3R4G,2G7G,5B,5R8R,9G7R9B,8R7R5G,7B9R1R8R,7R,9R1B", "6,8,7,2,1,5,4,10,3,9")
/*17*/ test("3G8B2B8G,7B7R5G,4B9G2R,4G,1G2R5R8R,1B,8R9G7G,7R6B,6B8B,3G3R,3R2R", "2,7,1,3,9,5,8,10,11,4,6")
/*18*/ test("5G3B,4B3G,7G8R2B7R,6G,1G,1B,1R9R2R7R,3R4G1R,4B3G2G8G,3B,2B1G,7R", "3,7,9,8,1,4,2,12,10,11,5,6")
/*19*/ test("4B2B5G1G,2G2B3R,7G4B9R9G,7R9G,5B,5G3G,7R5R,4B,6G3R4G3G,3R9G,8R9G4R,2R", "3,11,4,7,10,9,1,5,6,2,8,12")
/*20*/ test("8R,9R,5R,4G,3G2G1R,5G,4G5G,2G,6G6B1G,8R2G6B2G,1G5B8B,1G,7R", "10,9,2,1,11,13,3,7,6,4,5,8,12")
/*21*/ test("2R,4G7G,4R,1G1R7G,5B6G,2G,4B9R,7R2B7R4B,3B1G5G,8B9R,6B1G6R,1R2R,9G2B2R,4R9B", "10,11,14,8,13,5,7,2,3,4,9,1,12,6")
/*22*/ test("6R3R3B,1R,7R4B4G,7G9B,4G6G8B,4R7R4B,5R3R,3R,5B2G4R,1B,5B,9B2R,5G4R,6R3R3G", "4,3,5,12,9,14,6,11,1,13,7,8,2,10")
/*23*/ test("5B7B,8G,7G,6R9B3B,2B,3G3B8R7B,7R7G6R,4B6B5G,4R4G9R,4B7G6G5G,3B8B1B1G,5G7G2R,1B,2G6G5B3G,4R4B8B", "7,6,9,10,4,12,14,2,8,15,3,1,11,5,13")
/*24*/ test("8B9B,6R3B2G,5B,6R2R5R,3R1B,1R1R1B9B,4R4B9G9G,8R2B,6B,1B,2R,4B,6G7R,7G,3G2G7R,7B7G8G", "7,16,1,2,13,6,15,8,9,14,3,4,12,5,11,10")
/*25*/ test("8R,4G,8G5G,7G1R1R7R,6R,2G3B5B,7G3R1B,4B9G9G,5R4G5R7B,8B9B1B4G,5G9R1R,8B,7G1B,9B3R,2R9G,6G5G", "9,11,4,8,1,3,7,10,15,5,14,16,6,13,2,12")
/*26*/ test("1G3B8G,8R6B9B9B,7B,7R3B5G1B,3G,7B8G9B,2B2G6B6B,2B7G9R1B,2G8B6R8R,3R,9B3G5R2G,5B2R3R5B,8B4B,4G1R,2B,8R1B7B4R,9B", "6,2,9,11,8,1,4,7,16,12,17,13,14,3,5,10,15")
/*27*/ test("2B,6G1G6G4R,3B8B3B,9G,1R,3B,7R9G2R,6R1G4G6B,3B5G8G,8G1G3B4R,4G8G,6G2B5B,4G2G5R,1B,4G6G,3G1R9G,8B5R4B7R,4R3B", "7,8,17,10,2,9,13,16,18,4,12,11,15,3,6,1,5,14")
/*28*/ test("9G,6B3G1B4B,4B3R2R5G,2R1G,6B6R8B1R,4R3R1R,9R,8R8B,4G,3G9B,6G8B2R,5R8R6G,5B1B7B4B,2R3G1G3B,3R5B4R,8G5G,5G2B2R,8G", "5,11,12,3,8,15,10,16,1,7,2,13,6,18,14,17,4,9")
/*29*/ test("7B9R,2B3R1R2R,2G6B3G,6R,8G,6B7B6R,1R1G5B6G,9G,2R6G,7B6B9G5R,5G4G1B7B,4B9R2B5G,2G8B9G9G,8G3B5R,3G,2R,3R2B9B,8B3B,1R", "10,13,14,6,12,1,11,17,8,7,2,3,5,9,4,18,16,15,19")
/*30*/ test("8G6B9G,8G,7B4G2G6G,3B8R2R,4R1R3R8B,3G,2R1R,1R9G2B1G,4G8G,8B8B2R8R,2R1R1G,4B2B6R4B,6G9G3G6R,9B6B8R,9R7B,3G,5B4B,4B4G6B8B,4B5G,8B2R", "1,14,10,13,15,18,3,5,8,9,12,2,20,4,19,17,11,7,6,16")
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