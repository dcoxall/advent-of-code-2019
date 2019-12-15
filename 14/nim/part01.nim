# Day 14: Space Stoichiometry
# https://adventofcode.com/2019/day/14

import re, strutils, sequtils, tables

type
  Quantity = tuple
    count: int
    chem:  string

proc parseChemical(val: string): Quantity =
  let parts = val.split({ ' ' })
  result.count = parseInt(parts[0])
  result.chem = parts[1]

let input = open("./inputs/14.txt")

var reactions = initTable[string, (Quantity, seq[Quantity])]()

for line in input.lines:
  let splitPos = find(line, re"\s+=>\s+")
  let inputChems = line[..(splitPos-1)].split(re",\s+").map(parseChemical)
  let outputChem = parseChemical(line[(splitPos+4)..(len(line)-1)])
  reactions[outputChem.chem] = (outputChem, inputChems)

input.close()

var
  necessaryOre = 0
  stack = newSeq[Quantity]()
  excess = initTable[string, int]()
  chem: Quantity
  reaction: (Quantity, seq[Quantity])
  current = 0
  multiplier = 1

stack.add((1, "FUEL"))

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
        necessaryOre += req.count * multiplier
      else:
        stack.add((req.count * multiplier, req.chem))

    # recalculate the excess
    excess[chem.chem] = ((needed.count * multiplier) + current) - chem.count

echo necessaryOre
