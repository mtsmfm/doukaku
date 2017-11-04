require_relative './doukaku.rb'
require 'json'

def generate_random_data(width:, height:)
  ((1..width).to_a * height).shuffle.each_slice(width).map(&:sort)
end

def data_to_s(d)
  d.map {|xs| xs.map {|x| x.odd? ? ?o : ?x }.join }.join(?,)
end

data = []

[
  *([{width: 5, height: 2}] * 3),
  *([{width: 6, height: 2}] * 3),
  *([{width: 7, height: 2}] * 3),
  *([{width: 8, height: 2}] * 3),
  *([{width: 9, height: 2}] * 3),
  *([{width: 10, height: 2}] * 3),
  *([{width: 11, height: 2}] * 3),
  *([{width: 12, height: 2}] * 3)
].each do |params|
  data << generate_random_data(params)
end

data << [[1,1,3,3,5,5,7,7,9,9,11,11], [2,2,4,4,6,6,8,8,10,10,12,12]]

File.write("doukaku.json", JSON.pretty_generate(data.map.with_index {|original, i|
  input = data_to_s(original)

  p input

  {
    original: original,
    input:    input,
    expected: solve(input)
  }
}))
