# Day 1: The Tyranny of the Rocket Equation
# https://adventofcode.com/2019/day/1

# load the input
input = File.open("./inputs/01.txt")

# define a method to calculate the fuel based on mass
def calculate_fuel(mass)
  ((mass.to_i / 3) - 2)
end

# iterate over each line of input
total = input.each_line.reduce(0) do |fuel, module_mass|
  # calculate the module fuel
  module_fuel     = calculate_fuel(module_mass)
  # calculate the first additional fuel
  additional_fuel = calculate_fuel(module_fuel)

  # whilst we have positive additional fuel
  while additional_fuel > 0
    # add it to the modules total
    module_fuel += additional_fuel
    # recalculate the additional fuel on the latest additional fuel
    additional_fuel = calculate_fuel(additional_fuel)
  end

  # add the module fuel to the previous fuel value
  fuel + module_fuel
end

# output the fuel
puts total
