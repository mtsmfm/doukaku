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

    outputs << draw_rect(0, 0, board_size, board_size)

    yield(outputs)

    outputs.join("\n")
  end
end

def draw_rect(x, y, width, height, fill: "none")
  tag(:rect, x: x, y: y, width: width, height: height, style: "fill:#{fill};stroke:black")
end

def draw(input, board_size: 400)
  ominos = input.scan(/(\d+)(\D+)/).map {|pos, type| Tetromino.new(pos, type) }
  board = Board.new.tap {|b|
    ominos.each do |omino|
      b.add(omino)
    end
  }.to_a

  result = draw_base(board_size: board_size) do |outputs|
    delta = board_size / [board.map {|row| row.size }.max, board.size].max.to_f

    board.each.with_index do |row, y|
      row.each.with_index do |omino, x|
        if omino
          _x = x * delta
          _y = board_size - (y + 1) * delta
          color =
            case omino.type
            when "I"
              "#4B75B9"
            when "L"
              "#F8D32F"
            when "O"
              "#DEE735"
            when "S"
              "#D04255"
            when "T"
              "#1F91BE"
            end
          outputs << draw_rect(_x, _y, delta, delta, fill: color)
          outputs << content_tag(:text, x: _x + delta * 0.5, y: _y + delta * 0.5, 'text-anchor': "middle", 'dominant-baseline': "central", "font-size": delta / 3) { omino.id }
        end
      end
    end
  end

  tag(:img, src: "data:image/svg+xml;base64,#{Base64.encode64(result).gsub(/\n/,"")}")
end

data = %w(
  1O3L0I0T
  0I
  0I0I
  0I1I2I3I4I
  0S0I
  0I0S
  2S0T2O3I
  4O4T1T0S4L1L3L
  0S2S4S6S8S10S12S14S
  14S12S10S8S6S4S2S0S
)

(data.count..19).each do |n|
  data << (n * 3).times.map { "%d%s" % [(0..(n * 4 / 3)).to_a.sample, %w(I L O S T).sample] }.join
end

data += %w(
  999I999I999I999I999I999I999I999I999I999I999I
)

File.write("doukaku.json", data.map.with_index {|input, i|
  {
    input:    input,
    expected: solve(input),
    image:    draw(input)
  }
}.to_json)
