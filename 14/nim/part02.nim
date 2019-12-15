# Day 14: Space Stoichiometry
# https://adventofcode.com/2019/day/14#part2

import re, strutils, sequtils, tables

type
  Quantity = tuple
    count: int64
    chem:  string

proc parseChemical(val: string): Quantity =
  let parts = val.split({ ' ' })
  result.count = int64(parseInt(parts[0]))
  result.chem = parts[1]

let input = open("./inputs/14.txt")

var reactions = initTable[string, (Quantity, seq[Quantity])]()

for line in input.lines:
  let splitPos = find(line, re"\s+=>\s+")
  let inputChems = line[..(splitPos-1)].split(re",\s+").map(parseChemical)
  let outputChem = parseChemical(line[(splitPos+4)..(len(line)-1)])
  reactions[outputChem.chem] = (outputChem, inputChems)

input.close()

proc calcOreRequirement(n: int64, reactions: var Table[string, (Quantity, seq[Quantity])]): int64 =
  var
    stack = newSeq[Quantity]()
    excess = initTable[string, int64]()
    chem: Quantity
    reaction: (Quantity, seq[Quantity])
    current = int64(0)
    multiplier = int64(1)

  stack.add((n, "FUEL"))

  while len(stack) != 0:
    chem = stack[high(stack)]
    stack.delete(high(stack))
    reaction = reactions[chem.chem]
    let needed = reaction[0]
    current = excess.getOrDefault(needed.chem)
    if current >= chem.count:
      # we already have enough
      excess[chem.chem] = current - chem.count
    else:
      # we don't have enough so work out how many
      # reactions we need
      multiplier = (chem.count - current) div needed.count
      if (multiplier * needed.count) + current < chem.count:
        multiplier += 1

      for req in reaction[1]:
        if req.chem == "ORE":
          result += req.count * multiplier
        else:
          stack.add((req.count * multiplier, req.chem))

      # recalculate the excess
      excess[chem.chem] = ((needed.count * multiplier) + current) - chem.count

var
  fuel = int64(1)
  target = int64(1e12)
  ore = int64(-1)

while true:
  ore = calcOreRequirement(fuel + 1, reactions)
  if (ore > target):
    echo fuel
    break
  else:
    fuel = max(fuel + 1, (fuel + 1) * target div ore)
