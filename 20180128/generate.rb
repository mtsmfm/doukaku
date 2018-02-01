require_relative './doukaku.rb'
require 'json'

def generate_random_input(max_num:, dead_num:, member_num:, member_range:)
  loop do
    members = Array.new(member_num) do
      rand(member_range)
    end
    dead_indexes = dead_num.times.map do
      rand(members.size)
    end
    m_str = members.map.with_index do |m, i|
      dead_indexes.include?(i) ? "[#{m}]" : m
    end.join

    input = "#{m_str}/#{max_num}"
    result = solve(input)

    return input unless result.include?(?|) || result.empty?
  end
end

inputs = []

[
  *([max_num: 6, dead_num: 1, member_num: 3, member_range: 1..3] * 3),
  *([max_num: 6, dead_num: 2, member_num: 3, member_range: 1..3] * 3),
  *([max_num: 7, dead_num: 2, member_num: 4, member_range: 1..4] * 3),
  *([max_num: 8, dead_num: 3, member_num: 5, member_range: 1..4] * 3),
  *([max_num: 9, dead_num: 4, member_num: 6, member_range: 1..4] * 3),
  *([max_num: 10, dead_num: 5, member_num: 7, member_range: 1..5] * 3),
  *([max_num: 11, dead_num: 6, member_num: 8, member_range: 1..5] * 3),
  *([max_num: 12, dead_num: 7, member_num: 9, member_range: 1..5] * 3),
  *([max_num: 13, dead_num: 8, member_num: 10, member_range: 1..6] * 3),
  *([max_num: 15, dead_num: 10, member_num: 12, member_range: 1..9] * 3),
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
