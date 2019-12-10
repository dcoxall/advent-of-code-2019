# Day 10: Monitoring Station
# https://adventofcode.com/2019/day/10#part2

require 'set'

class Point < Struct.new(:x, :y)
  def +(other)
    Point.new(x + other.x, y + other.y)
  end

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

  def distance
    x.abs + y.abs
  end

  def rotation
    ((Math.atan2(y, x) / Math::PI * 180) + 90) % 360
  end
end

asteroids = Set.new
File.read("./inputs/10.txt").lines.each_with_index do |row, y|
  row.chars.each_with_index do |cell, x|
    asteroids.add(Point.new(x, y)) if cell == '#'
  end
end

base, rots = asteroids.reduce([nil, {}]) do |(current_base, current_rotations), candidate|
  # draw a line to each target
  rotations = asteroids.each_with_object(Hash.new { |h, k| h[k] = [] }) do |target, hash|
    # skip drawing a line to ourselves
    next if target == candidate

    # calculate the diff and add the rotation to the hash along with all
    # the points following that rotation
    c = target - candidate
    vec = Vector2.new(c.x, c.y)
    hash[vec.rotation].push(vec)
  end

  rotations.transform_values! { |vals| vals.sort_by!(&:distance).map { |v| candidate + v } }

  # if we have more unique rotations then make this the new base
  if rotations.count > current_rotations.count
    [candidate, rotations]
  else
    [current_base, current_rotations]
  end
end

rotation_keys = rots.keys.sort
rotation_count = 0
last_point = nil
while rotation_count < 200
  key = rotation_keys[0]
  rotation_keys.rotate!

  if point = rots[key].shift
    last_point = point
    rotation_count += 1
  end
end

puts last_point.x * 100 + last_point.y
