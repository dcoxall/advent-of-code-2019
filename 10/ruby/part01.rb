# Day 10: Monitoring Station
# https://adventofcode.com/2019/day/10

require 'set'

class Point < Struct.new(:x, :y)
  def -(other)
    Point.new(x - other.x, y - other.y)
  end

  def to_s
    format("(%02d, %02d)", x, y)
  end
end

class Vector2 < Struct.new(:x, :y)
  def to_s
    format("(%02d, %02d)", x, y)
  end

  def rotation
    (Math.atan2(y, x) / Math::PI * 180) % 360
  end
end

asteroids = Set.new
File.read("./inputs/10.txt").lines.each_with_index do |row, y|
  row.chars.each_with_index do |cell, x|
    asteroids.add(Point.new(x, y)) if cell == '#'
  end
end

_, rots = asteroids.reduce([nil, []]) do |(current_base, current_rotations), candidate|
  # draw a line to each target
  rotations = asteroids.each_with_object(Set.new) do |target, set|
    # skip drawing a line to ourselves
    next if target == candidate

    # calculate the diff and add the rotation into the set
    c = target - candidate
    set.add(Vector2.new(c.x, c.y).rotation)
  end

  # if we have more unique rotations then make this the new base
  if rotations.count > current_rotations.count
    [candidate, rotations]
  else
    [current_base, current_rotations]
  end
end

puts rots.count
