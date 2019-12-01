# Day 1: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1

import strutils

let input = open("./inputs/01.txt")
var fuel = 0

for line in input.lines:
  fuel += int((parseInt(line) / 3) - 2)

input.close()

echo fuel
