# Day 6: Universal Orbit Map
# https://adventofcode.com/2019/day/6#part2

import tables, strutils, sequtils

let input = open("./inputs/06.txt")
var orbits = initTable[string, string]()

for line in input.lines:
  let planets = line.split({ ')' }).mapIt(strip(it))
  orbits[planets[1]] = planets[0]

input.close()

var fromYou = initTable[string, int]()
var dist = 0
var planet = orbits["YOU"]

while orbits.contains(planet):
  fromYou[planet] = dist
  planet = orbits[planet]
  dist += 1

planet = orbits["SAN"]
dist = 0

while orbits.contains(planet):
  if fromYou.contains(planet):
    echo dist + fromYou[planet]
    break
  planet = orbits[planet]
  dist += 1
