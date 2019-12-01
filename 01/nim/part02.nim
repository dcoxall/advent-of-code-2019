# Day 1: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1#part2

import strutils

let input = open("./inputs/01.txt")

proc fuelRequirement(mass: int): int =
  result = int((mass / 3) - 2)
  if result > 0:
    result += fuelRequirement result
  else:
    result = 0

var fuel = 0
for line in input.lines:
  fuel += fuelRequirement parseInt(line)

input.close()

echo fuel
