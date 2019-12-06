# Day 6: Universal Orbit Map
# https://adventofcode.com/2019/day/6

input = File.read('./inputs/06.txt')
orbits = {}

input.lines.each do |line|
  a, b = line.split(')').map(&:strip)
  orbits[b] = a
end

count = 0
orbits.each_key do |planet|
  while planet = orbits[planet]
    count += 1
  end
end

puts count
