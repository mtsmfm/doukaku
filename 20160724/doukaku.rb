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
  end.map(&:id).join
end

TEST_DATA = <<~EOS
/*1*/ test( "1R2G2G,1R2G2G,9B", "312" );
/*2*/ test( "1R2G2G,7B", "12" );
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
