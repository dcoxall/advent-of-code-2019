# Day 12: The N-Body Problem
# https://adventofcode.com/2019/day/12#part2

import re, strutils, sequtils, sugar, intsets, math, sets

let input = open("./inputs/12.txt")

type
  Dimension = tuple
    a, b: int

  Vector3 = tuple
    x, y, z: int

  Moon = object
    pos, vel: Vector3

proc `+=`(a: var Vector3, b: Vector3) =
  a.x += b.x
  a.y += b.y
  a.z += b.z

proc lcm(vals: IntSet): int64 =
  result = int64(-1)
  for n in vals:
    if result < 0:
      result = int64(n)
    else:
      result = lcm(result, int64(n))

proc lcm(vals: HashSet[int64]): int64 =
  result = int64(-1)
  for n in vals:
    if result < 0:
      result = n
    else:
      result = lcm(result, n)

proc calcGravity(a, b: Vector3): Vector3 =
  result.x = cmp(b.x, a.x)
  result.y = cmp(b.y, a.y)
  result.z = cmp(b.z, a.z)

proc findRepeat(moons: seq[Moon], cb: proc(moon: Moon): Dimension): int =
  var
    vals = initHashSet[seq[Dimension]]()
    moonsCopy = moons
  result = 0
  while not vals.containsOrIncl(map(moonsCopy, cb)):
    for i, currentMoon in moonsCopy:
      for targetMoon in moonsCopy:
        moonsCopy[i].vel += calcGravity(currentMoon.pos, targetMoon.pos)

    for i, moon in moonsCopy:
      moonsCopy[i].pos += moon.vel

    result += 1

var moons = newSeq[Moon]()

for line in input.lines:
  let parts = findAll(line, re"-?\d+").mapIt(parseInt(it))
  add(moons, Moon(pos: (parts[0], parts[1], parts[2]), vel: (0, 0, 0)))

input.close()

var repeatingVals = initIntSet()
# locate the first repeats for each dimension (x, y and z)
repeatingVals.incl(findRepeat(moons, (moon) => (moon.pos.x, moon.vel.x)))
repeatingVals.incl(findRepeat(moons, (moon) => (moon.pos.y, moon.vel.y)))
repeatingVals.incl(findRepeat(moons, (moon) => (moon.pos.z, moon.vel.z)))

echo lcm(repeatingVals)
