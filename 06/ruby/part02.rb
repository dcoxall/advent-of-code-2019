# Day 6: Universal Orbit Map
# https://adventofcode.com/2019/day/6#part2

input = File.read('./inputs/06.txt')
orbits = {}

input.lines.each do |line|
  a, b = line.split(')').map(&:strip)
  orbits[b] = a
end

distance_from_you = {}
planet = 'YOU'
n = 0
while planet = orbits[planet]
  distance_from_you[planet] = n
  n += 1
end

planet = 'SAN'
n = 0
while planet = orbits[planet]
  if distance = distance_from_you[planet]
    puts n + distance
    break
  end
  n += 1
end
