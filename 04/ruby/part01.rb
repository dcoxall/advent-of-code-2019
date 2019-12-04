# Day 4: Secure Container
# https://adventofcode.com/2019/day/4#part2

def sorted?(chars)
  chars.sort == chars
end

def paired?(chars)
  lookup = Hash.new { |h, k| h[k] = 0 }
  chars.each { |char| lookup[char] += 1 }
  lookup.values.any? { |count| count > 1 }
end

a, b = File.read('./inputs/04.txt').split('-').map(&:to_i)
count = 0

while a <= b
  bytes = a.to_s.bytes
  count += 1 if sorted?(bytes) && paired?(bytes)
  a += 1
end

puts count
