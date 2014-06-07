require 'bundler/setup'
Bundler.require

class Cell
  attr_accessor :val

  delegate :blank?, :present, to: :@val

  def initialize(x, y, w, h)
    @val = nil
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def adjacent_list
    return @list if @list

    @list = []

    if @x > 0
      @h.times do |i|
        @list << [@x - 1, @y + i]
      end
    end

    if @y > 0
      @w.times do |i|
        @list << [@x + i, @y - 1]
      end
    end

    @list
  end

  def add(other)
    unless self.equal? other
      @val ||= 0
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

  cells = Array.new(x) {|i| Array.new(y) {|j| Cell.new(i, j, 1, 1) } }

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

  cell = Cell.new(x, y, w, h)

  w.times do |i|
    h.times do |j|
      cells[x + i][y + j] = cell
    end
  end
end

def calc(cells)
  until cells.all? {|row| row.all?(&:present?) }
    cells.each.with_index {|row, x| row.each.with_index {|cell, y|
      next if cell.present?

      targets = cell.adjacent_list.map {|(x, y)| cells[x][y] }

      next if targets.any?(&:blank?)

      targets.each {|t| cell.add(t) }

      cell.cutoff!
    }}
  end
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
