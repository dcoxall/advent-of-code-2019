# Day 6: Universal Orbit Map
# https://adventofcode.com/2019/day/6

import tables, strutils, sequtils

let input = open("./inputs/06.txt")
var orbits = initTable[string, string]()

for line in input.lines:
  let planets = line.split({ ')' }).mapIt(strip(it))
  orbits[planets[1]] = planets[0]

var total = 0
for planet in orbits.keys:
  var current = planet
  while orbits.contains(current):
    total += 1
    current = orbits[current]

input.close()

echo total
