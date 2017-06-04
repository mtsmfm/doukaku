require_relative './doukaku.rb'
require 'erb'
require 'json'

def content_tag(tag, attributes={})
  <<~HTML
    <#{tag} #{attributes.map {|k, v| %|#{k}="#{Array(v).join(' ')}"| }.join(' ')}>
      #{yield}
    </#{tag}>
  HTML
end

def tag(tag, attributes={})
  content_tag(tag, attributes) {}
end

def draw_base(board_size: 400, padding: 30)
  content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: board_size + padding, height: board_size + padding, viewBox: "-#{padding} -#{padding} #{board_size + padding * 2} #{board_size + padding*2}") do
    outputs = []

    yield(outputs)

    outputs.join("\n")
  end
end

def draw_rect(x, y, width, height, fill: "none", stroke: "black", stroke_width: 1)
  tag(:rect, x: x, y: y, width: width, height: height, style: "fill:#{fill};stroke:#{stroke}", "stroke-width": stroke_width)
end

def positions_for(number)
  case number
  when 1
    [[0, 0]]
  when 2
    [
      [-1, -1],
      [+1, +1]
    ]
  when 3
    positions_for(2) + positions_for(1)
  when 4
    positions_for(2) + [
      [+1, -1],
      [-1, +1]
    ]
  when 5
    positions_for(4) + positions_for(1)
  when 6
    positions_for(4) + [
      [0, -1],
      [0, +1]
    ]
  end
end

def draw_dice(x, y, width, height, number, here: false)
  dx = width / 5.0
  dy = height / 5.0

  center_x = x + width / 2.0
  center_y = y + height / 2.0
  r = width / 15.0

  dice = case number
  when 1
    tag(:circle, cx: center_x, cy: center_y, r: r * 1.5, stroke: :black, "stroke-width": 3, fill: :red)
  else
    positions_for(number).map {|_x, _y|
      tag(:circle, cx: center_x + dx * _x, cy: center_y + dy * _y, r: r, stroke: :black, "stroke-width": 3)
    }.join
  end

  (here ? draw_rect(x, y, width, height, stroke: :red, stroke_width: 3) : "") + draw_rect(x, y, width, height, stroke: :black, stroke_width: 1) + dice
end

def draw(input, board_size: 400)
  omino = parse(input)

  result = draw_base(board_size: board_size) do |outputs|
    delta = board_size / [omino.width, omino.height].max.to_f

    positions = positions(input)

    omino.each_with_index do |col, x, y|
      outputs << draw_dice(x * delta, y * delta, delta, delta, col, here: positions.any? {|p| p.include?([x, y]) })
    end
  end

  tag(:img, src: "data:image/svg+xml;base64,#{Base64.encode64(result).gsub(/\n/,"")}")
end

def generate_data_contain(omino, width: 5, height: 5, count: 1)
  loop do
    a, b, c = [[1, 6], [2, 5], [3, 4]].map(&:shuffle).shuffle.map(&:first)
    _a = _b = _c = false

    data = generate_random_data(width: width, height: height, count: 0)
    board = parse(data).array

    offset_x = rand(0..width - omino.width).to_i
    offset_y = rand(0..height - omino.height).to_i

    omino.each_with_index do |col, x, y|
      case col
      when ?a, ?b, ?c
        val = binding.local_variable_get(col)
        assigned = binding.local_variable_get("_#{col}")

        board[y + offset_y][x + offset_x] = assigned ? 7 - val : val

        binding.local_variable_set("_#{col}", true)
      end
    end

    data = board.map(&:join).join(?,)
    return data if positions(data).count == count
  end
end

def generate_random_data(width: 5, height: 5, count: 1)
  board = Array.new(height) { Array.new(width) { rand(1..6) } }

  loop do
    data = board.map(&:join).join(?,)
    ps = positions(data)

    return data if ps.count == count

    puts "#{width} x #{height}: expected #{count} but got #{ps.count}"

    ps.sample(ps.count - count).each do |p|
      p.each do |x, y|
        board[y][x] = rand(1..6)
      end
    end
  end
end

data = OMINOS.flat_map do |omino|
  [
    generate_data_contain(omino, width: omino.width, height: omino.height),
    generate_random_data(width: omino.width, height: omino.height, count: 0)
  ]
end

(5..7).each do |i|
  data << generate_random_data(width: i, height: i, count: 0)
  data << generate_random_data(width: i, height: i, count: 0)
  data << generate_data_contain(OMINOS.sample, width: i, height: i, count: 1)
end

data = data.shuffle.sort_by(&:length)

File.write("doukaku.json", data.map.with_index {|input, i|
  {
    input:    input,
    expected: solve(input),
    image:    draw(input)
  }
}.to_json)

missed_data = %w(
  16161,61616,16161
  2431,6354,2341
)

File.write("doukaku2.json", missed_data.map.with_index {|input, i|
  {
    input:    input,
    expected: solve(input),
    image:    draw(input)
  }
}.to_json)
