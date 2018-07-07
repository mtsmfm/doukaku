require_relative './doukaku.rb'
require 'json'

def generate_random_input(x:, y:, answer_count:)
  loop do
    p_x = [*0...x].sample
    p_y = [*0...y].sample

    input = "#{x},#{y},(#{p_x},#{p_y})"
    result = _solve(input)

    if (result&.count || 0) == answer_count
      return input
    end
  end
end

inputs = [
  "4,7,(0,3)",
  "4,6,(3,3)",
  "1,1,(0,0)",
  "2,2,(0,0)",
  "2,3,(0,0)",
  "2,3,(0,1)",
  "2,3,(1,1)",
  "2,3,(1,2)",
  "3,4,(1,2)",
  "4,3,(2,2)",
]

[
  {x: 7,   y: 7,   answer_count: 1},
  {x: 8,   y: 7,   answer_count: 1},
  {x: 9,   y: 7,   answer_count: 1},
  {x: 10,  y: 7,   answer_count: 1},
  {x: 10,  y: 11,  answer_count: 1},
  {x: 10,  y: 12,  answer_count: 1},
  {x: 10,  y: 13,  answer_count: 0},
  {x: 10,  y: 14,  answer_count: 1},
  {x: 15,  y: 15,  answer_count: 1},
  {x: 16,  y: 17,  answer_count: 1},
  {x: 19,  y: 7,   answer_count: 0},
  {x: 20,  y: 7,   answer_count: 1},
  {x: 25,  y: 11,  answer_count: 1},
  {x: 26,  y: 12,  answer_count: 1},
  {x: 27,  y: 13,  answer_count: 1},
  {x: 28,  y: 14,  answer_count: 2},
  {x: 30,  y: 30,  answer_count: 1},
  {x: 35,  y: 36,  answer_count: 1},
  {x: 150, y: 130, answer_count: 1},
  {x: 180, y: 120, answer_count: 2},
  {x: 200, y: 200, answer_count: 1},
].lazy.each do |params|
  inputs << generate_random_input(params)
end

File.write("doukaku.json", JSON.pretty_generate(inputs.map.with_index {|input, i|
  p input

  {
    input:    input,
    expected: solve(input)
  }
}))
