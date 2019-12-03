# Day 3: Crossed Wires
# https://adventofcode.com/2019/day/3

import algorithm, strutils, sequtils, sets

type
  Direction {.pure.} = enum
    Up, Down, Left, Right

  Instruction = tuple
    dir: Direction
    count: int

  Coord = tuple[x: int, y: int]

proc executeInstruction(ins: Instruction, current: Coord): seq[Coord] =
  case ins.dir:
    of Direction.Up:
      for n in 1..ins.count:
        result.add (current.x, current.y - n)
    of Direction.Down:
      for n in 1..ins.count:
        result.add (current.x, current.y + n)
    of Direction.Left:
      for n in 1..ins.count:
        result.add (current.x - n, current.y)
    of Direction.Right:
      for n in 1..ins.count:
        result.add (current.x + n, current.y)

proc parseDirection(value: char): Direction =
  case value:
    of 'U':
      Direction.Up
    of 'D':
      Direction.Down
    of 'L':
      Direction.Left
    else:
      Direction.Right

proc parse(value: string): Instruction =
  (dir: parseDirection(value[0]), count: parseInt(value[1..len(value)-1]))

proc manhattanDistance(coord: Coord): int =
  abs(coord.x) + abs(coord.y)

let input = open("./inputs/03.txt")
var coordinates = newSeq[HashSet[Coord]]()

for line in input.lines:
  var
    instruction: Instruction

    current = (0, 0)
    visited = initHashSet[Coord]()

  for value in line.split({ ',' }):
    instruction = parse(value)
    for coord in executeInstruction(instruction, current):
      visited.incl(coord)
      current = coord

  coordinates.add(visited)

input.close()

var intersect = toSeq(intersection(coordinates[0], coordinates[1]))
var distances = intersect.map(manhattanDistance)
distances.sort(system.cmp)
echo distances[0]
