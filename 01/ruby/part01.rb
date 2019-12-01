# Day 1: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1

# load the input
input = File.open("./inputs/01.txt")

# iterate over each line of input
total = input.each_line.reduce(0) do |fuel, module_mass|
  # add the module fuel to the previous fuel value
  fuel + ((module_mass.to_i / 3) - 2)
end

# output the fuel
puts total
