# Day 8: Space Image Format
# https://adventofcode.com/2019/day/8

input = File.read('./inputs/08.txt').chomp.chars

WIDTH  = 25
HEIGHT =  6

zero_count     = nil
selected_layer = nil

while !input.empty?
  layer = input.take(WIDTH * HEIGHT)
  input = input.drop(WIDTH * HEIGHT)
  tmp_count = layer.count("0")
  if zero_count.nil? || tmp_count < zero_count
    zero_count = tmp_count
    selected_layer = layer
  end
end

puts selected_layer.count("1") * selected_layer.count("2")
