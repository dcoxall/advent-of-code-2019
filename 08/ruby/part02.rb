# Day 8: Space Image Format
# https://adventofcode.com/2019/day/8#part2

input = File.read('./inputs/08.txt').chomp.chars

WIDTH  = 25
HEIGHT =  6

flattened = Array.new(WIDTH * HEIGHT) { 2 }
while !input.empty?
  layer = input.take(WIDTH * HEIGHT)
  input = input.drop(WIDTH * HEIGHT)
  layer.each_with_index do |pixel, i|
    if flattened[i] == 2
      flattened[i] = pixel.to_i
    end
  end
end

while !flattened.empty?
  row = flattened.take(WIDTH)
  flattened = flattened.drop(WIDTH)
  pixels = row.map do |pixel|
    if pixel == 1
      '█'
    else
      ' '
    end
  end
  puts pixels.join('')
end
