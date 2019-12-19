# Day 18: Many-Worlds Interpretation
# https://adventofcode.com/2019/day/18

import sequtils, sets, tables

type
  Vector2D = tuple
    x, y: int

  Grid = seq[seq[char]]

  Keys = HashSet[char]

  KeyWithVec = tuple
    keys: Keys
    pos: Vector2D

  State = tuple
    keys: Keys
    pos: Vector2D
    steps: int

let
  file = open("./inputs/18.txt")
  input = mapIt(toSeq(file.lines), toSeq(it))

file.close()

# cell is A..Z
func isDoor(cell: char): bool = ord(cell) >= ord(char('A')) and ord(cell) <= ord(char('Z'))
# cell is a..z
func isKey(cell: char): bool = ord(cell) >= ord(char('a')) and ord(cell) <= ord(char('z'))
# cell is #
func isWall(cell: char): bool = cell == '#'

# used to identify where the player is in the grid
# and convert it to a Vector2D
func locatePos(grid: Grid): Vector2D =
  for y, row in grid:
    for x, cell in row:
      if cell == '@':
        return (x, y)

func locateKeys(grid: Grid): HashSet[char] =
  for y, row in grid:
    for x, cell in row:
      if isKey(cell):
        result.incl(cell)

func adjacent(vec: Vector2D): HashSet[Vector2D] =
  return toHashSet([
    (vec.x + 1, vec.y),
    (vec.x - 1, vec.y),
    (vec.x, vec.y + 1),
    (vec.x, vec.y - 1),
  ])

func withinBounds(grid: Grid, vec: Vector2D): bool =
  result = true
  if vec.y > high(grid) or vec.y < low(grid):
    result = false
  elif vec.x > high(grid[0]) or vec.x < low(grid[0]):
    result = false

func compute(grid: Grid): int =
  var
    visited: HashSet[KeyWithVec]
    states: seq[State]

    pos     = locatePos(grid)
    allKeys = locateKeys(grid)

  visited.incl((initHashSet[char](), pos))
  states.add((initHashSet[char](), pos, 0))

  while true:
    var nextStates: seq[State]

    for (keys, position, steps) in states:
      for candidate in adjacent(position):
        let c = grid[candidate.y][candidate.x]

        if not withinBounds(grid, candidate) or (keys, candidate) in visited or isWall(c):
          continue
        elif isDoor(c):
          let key = char(ord(c) + 32)
          if key notin keys:
            continue

        var candidateKeys = keys
        if isKey(c) and c notin keys:
          candidateKeys.incl(c)

        visited.incl((keys, candidate))
        nextStates.add((candidateKeys, candidate, steps + 1))

        if keys == allKeys:
          return steps

    states = nextStates

echo compute(input)
