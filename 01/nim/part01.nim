# Day 1: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1

# import strutils so we can use parseInt
import strutils

# load the input
let input = open("./inputs/01.txt")

# initialize our fuel
var fuel = 0

# iterate over each line of input
for line in input.lines:
  # add the new fuel calculation to running fuel total
  # we need to convert the line into an integer using parseInt
  fuel += int((parseInt(line) / 3) - 2)

# close the input file as we don't need it anymore
input.close()

# output the fuel
echo fuel
