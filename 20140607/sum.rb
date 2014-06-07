require 'bundler/setup'
Bundler.require

class Cell
  attr_accessor :val

  def initialize
    @val = nil
  end

  def add(other)
    unless self.equal? other
      @val += other.val
    end
  end

  def cutoff!
    @val = @val.to_s.last(2).to_i
  end

  def inspect
    val.inspect + " : (#{object_id})"
  end

  def to_s
    '%02d' % val
  end
end

def solve(input)
  x, y = input.scan(/(\d+)x(\d+):/).first.map(&:to_i)
  rects = input.scan(/:(.*)/).first.first.split(?,).map {|r| r.each_char.map(&:to_i) }

  cells = Array.new(x) { Array.new(y) { Cell.new } }

  rects.each do |rect|
    link(cells, rect)
  end

  cells[0][0].val = 1

  calc(cells)

  binding.pry

  cells.last.last.to_s
end

def link(cells, rect)
  x, y, w, h = rect

  cell = Cell.new

  w.times do |i|
    h.times do |j|
      cells[x + i][y + j] = cell
    end
  end
end

def calc(cells)
  cells.each.with_index {|row, x| row.each.with_index {|cell, y|
    if x > 0
      cell.add(cells[x - 1][y])
    end
    if y > 0
      cell.add(cells[x][y - 1])
    end
    binding.pry if x == 0 && y == 5
    cell.cutoff!
  }}
end

DATA.each_line.with_index do |line, i|
  input, expect = line.scan(/"(.*)", "(.*)"/).first
  actual = solve(input)
  print i
  raise("#{input} expected: #{expect.inspect}, got: #{actual.inspect}") unless actual == expect

  print '.'
end

p 'passed! yey!'

__END__
/*0*/ test( "8x6:6214,3024,5213,5022,0223,7115", "32" );
