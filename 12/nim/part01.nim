# Day 12: The N-Body Problem
# https://adventofcode.com/2019/day/12

import re, strutils, sequtils

let input = open("./inputs/12.txt")

type
  Vector3 = tuple
    x, y, z: int

  Moon = object
    pos, vel: Vector3

proc `+=`(a: var Vector3, b: Vector3) =
  a.x += b.x
  a.y += b.y
  a.z += b.z

proc abs(a: Vector3): int = abs(a.x) + abs(a.y) + abs(a.z)

proc calcGravity(a, b: Vector3): Vector3 =
  result.x = cmp(b.x, a.x)
  result.y = cmp(b.y, a.y)
  result.z = cmp(b.z, a.z)

proc potential(a: Moon): int = abs(a.pos)
proc kinetic(a: Moon): int = abs(a.vel)
proc total(a: Moon): int = a.potential() * a.kinetic()

var moons = newSeq[Moon]()

for line in input.lines:
  let parts = findAll(line, re"-?\d+").mapIt(parseInt(it))
  add(moons, Moon(pos: (parts[0], parts[1], parts[2]), vel: (0, 0, 0)))

input.close()

for timeStep in (1..1_000):
  for i, currentMoon in moons:
    for targetMoon in moons:
      moons[i].vel += calcGravity(currentMoon.pos, targetMoon.pos)

  for i, moon in moons:
    moons[i].pos += moon.vel

echo foldl(moons, a + b.total(), 0)
