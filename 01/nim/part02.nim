# Day 1: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1#part2

# import strutils so we can use parseInt
import strutils

# load the input
let input = open("./inputs/01.txt")

# define a procedure to calculate the fuel
proc calcFuel(mass: int): int =
  result = int((mass / 3) - 2)
  return

# initialize the variables used in our loop
# this is good practice to avoid registering
# new areas of memory for each item in the loop
var
  # fuel stores the total
  fuel = 0
  # moduleFuel stores the fuel for the current module
  moduleFuel = 0
  # additionalFuel stores the most recent fuel calculation
  # for the current module
  additionalFuel = 0

for line in input.lines:
  # calculate the current module fuel
  moduleFuel     = calcFuel(parseInt(line))
  # calculate the first value for additional fuel
  additionalFuel = calcFuel(moduleFuel)

  # while we have a positive additional fuel value
  while additionalFuel > 0:
    # add it to the modules fuel
    moduleFuel += additionalFuel
    # and then recalculate the additional fuel
    additionalFuel = calcFuel(additionalFuel)

  # add the modules total fuel to the total
  fuel += moduleFuel

# close the unused input
input.close()

# output the fuel
echo fuel
