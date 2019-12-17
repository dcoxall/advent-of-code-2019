# Day 17: Set and Forget
# https://adventofcode.com/2019/day/17#part2

import tables, math, sequtils, strutils, sets

type
  Program = object
    memory:       Table[int64, int64]
    address:      int64
    relativeBase: int64
    paused:       bool
    halted:       bool
    inputs:       seq[int64]
    outputs:      seq[int64]

  Instruction = object
    opcode: int
    modes:  seq[int]

  Vector2D = tuple
    x, y: int

proc initProgram(mem: openArray[int64]): Program =
  var
    memory  = initTable[int64, int64]()
    inputs  = newSeq[int64]()
    outputs = newSeq[int64]()

  for i, n in mem:
    memory[int64(i)] = n

  result = Program(
    memory:       memory,
    address:      0,
    relativeBase: 0,
    paused:       false,
    halted:       false,
    inputs:       inputs,
    outputs:      outputs,
  )

proc parseInstruction(num: int64): Instruction =
  var
    digits = newSeq[int](5)
    n      = num

  for i in (0..4):
    digits[i] = int(n mod 10)
    n = n div int64(10)

  let opcode = digits[1] * 10 + digits[0]

  result = Instruction(
    opcode: opcode,
    modes:  digits[2 .. len(digits) - 1],
  )

proc param(prog: var Program, modes: seq[int], n: int64): int64 =
  case modes[n]:
  of 0:
    result = prog.memory[prog.address + n + 1]
  of 1:
    result = prog.address + n + 1
  else:
    result = prog.memory[prog.address + n + 1] + prog.relativeBase

proc opAdd(prog: var Program, a: int64, b: int64, c: int64) =
  prog.memory[c] = prog.memory[a] + prog.memory[b]
  prog.address += 4

proc opMultiply(prog: var Program, a: int64, b: int64, c: int64) =
  prog.memory[c] = prog.memory[a] * prog.memory[b]
  prog.address += 4

proc opInput(prog: var Program, a: int64) =
  if len(prog.inputs) == 0:
    prog.paused = true
  else:
    prog.memory[a] = prog.inputs[0]
    prog.inputs = prog.inputs[1 .. high(prog.inputs)]
    prog.address += 2

proc opOutput(prog: var Program, a: int64) =
  prog.outputs.add(prog.memory[a])
  prog.address += 2

proc opJmpTrue(prog: var Program, a: int64, b: int64) =
  if prog.memory[a] != 0:
    prog.address = prog.memory[b]
  else:
    prog.address += 3

proc opJmpFalse(prog: var Program, a: int64, b: int64) =
  if prog.memory.getOrDefault(a) == 0:
    prog.address = prog.memory[b]
  else:
    prog.address += 3

proc opLessThan(prog: var Program, a: int64, b: int64, c: int64) =
  if prog.memory[a] < prog.memory[b]:
    prog.memory[c] = 1
  else:
    prog.memory[c] = 0

  prog.address += 4

proc opEquals(prog: var Program, a: int64, b: int64, c: int64) =
  if prog.memory[a] == prog.memory[b]:
    prog.memory[c] = 1
  else:
    prog.memory[c] = 0

  prog.address += 4

proc opAdjustBaseOffset(prog: var Program, a: int64) =
  prog.relativeBase += prog.memory[a]
  prog.address += 2

proc opHalt(prog: var Program) =
  prog.address += 1
  prog.halted = true

proc executeInstruction(prog: var Program, inst: Instruction) =
  case inst.opcode:
  of 1:
    prog.opAdd(prog.param(inst.modes, 0), prog.param(inst.modes, 1), prog.param(inst.modes, 2))
  of 2:
    prog.opMultiply(prog.param(inst.modes, 0), prog.param(inst.modes, 1), prog.param(inst.modes, 2))
  of 3:
    prog.opInput(prog.param(inst.modes, 0))
  of 4:
    prog.opOutput(prog.param(inst.modes, 0))
  of 5:
    prog.opJmpTrue(prog.param(inst.modes, 0), prog.param(inst.modes, 1))
  of 6:
    prog.opJmpFalse(prog.param(inst.modes, 0), prog.param(inst.modes, 1))
  of 7:
    prog.opLessThan(prog.param(inst.modes, 0), prog.param(inst.modes, 1), prog.param(inst.modes, 2))
  of 8:
    prog.opEquals(prog.param(inst.modes, 0), prog.param(inst.modes, 1), prog.param(inst.modes, 2))
  of 9:
    prog.opAdjustBaseOffset(prog.param(inst.modes, 0))
  else:
    prog.opHalt()

proc execute(prog: var Program) =
  while not prog.halted and not prog.paused:
    let instruction = parseInstruction(prog.memory[prog.address])
    prog.executeInstruction(instruction)

proc resume(prog: var Program, vals: varargs[int64]) =
  for val in vals:
    prog.inputs.add(val)
  prog.paused = false
  prog.execute()

iterator items(prog: var Program): int64 =
  while len(prog.outputs) > 0:
    yield prog.outputs[0]
    prog.outputs = prog.outputs[1 .. high(prog.outputs)]

proc intoGrid(intcode: var Program): seq[seq[char]] =
  let output = toSeq(intcode).foldl(a & char(int(b)), "")
  result = output.split({ '\n' }).mapIt(toSeq(it))

proc handleOutput(intcode: var Program) =
  for v in intcode:
    if ord(high(char)) < int(v):
      echo v
      continue

    write(stderr, char(int(v)))
    flushFile(stderr)


# freaking ugly procedure BUT at least it lacks any magic
proc neighbouring(grid: seq[seq[char]], current: Vector2D): HashSet[Vector2D] =
  let
    width  = high(grid[0])
    height = high(grid)

  if current.x < width and grid[current.y][current.x + 1] == '#':
    result.incl((current.x + 1, current.y))
    if current.x < (width - 1) and grid[current.y][current.x + 2] == '#':
      result.incl((current.x + 2, current.y))

  if current.x > 0 and grid[current.y][current.x - 1] == '#':
    result.incl((current.x - 1, current.y))
    if current.x > 1 and grid[current.y][current.x - 2] == '#':
      result.incl((current.x - 2, current.y))

  if current.y < height and grid[current.y + 1][current.x] == '#':
    result.incl((current.x, current.y + 1))
    if current.y < (height - 1) and grid[current.y + 2][current.x] == '#':
      result.incl((current.x, current.y + 2))

  if current.y > 0 and grid[current.y - 1][current.x] == '#':
    result.incl((current.x, current.y - 1))
    if current.y > 1 and grid[current.y - 2][current.x] == '#':
      result.incl((current.x, current.y - 2))

# another ugly procedure which works out the new orientation and the direction of rotation
proc calculateRotation(orientation: char, pos: Vector2D, target: Vector2D): (char, char) =
  let rots = @['^', '>', 'v', '<']

  if target.x > pos.x:
    result[1] = '>'
  elif target.x < pos.x:
    result[1] = '<'
  elif target.y > pos.y:
    result[1] = 'v'
  else:
    result[1] = '^'

  let
    currentIndex = find(rots, orientation)
    nextIndex    = find(rots, result[1])

  # two special cases to handle the wrap around of the array
  if currentIndex == low(rots) and nextIndex == high(rots):
    result[0] = 'L'
  elif currentIndex == high(rots) and nextIndex == low(rots):
    result[0] = 'R'
  # and then the normal logic
  elif currentIndex < nextIndex:
    result[0] = 'R'
  else:
    result[0] = 'L'

proc compress(path: seq[(char, string)]): (string, Table[char, string]) =
  var
    previous   = $path[0][0] & "," & path[0][1]
    dictionary: HashSet[string]
    inverted:   Table[string, char]
    currentIndex = 'A'

  for i, movement in path:
    if i == 0:
      continue

    let
      part = $movement[0] & "," & movement[1]
      combined = previous & "," & part

    if dictionary.contains(combined):
      previous = combined
    else:
      dictionary.incl(combined)
      previous = part

  # given the dictionary now lets try again
  previous = $path[0][0] & "," & path[0][1]
  for i, movement in path:
    if i == 0:
      continue

    let
      part = $movement[0] & "," & movement[1]
      combined = previous & "," & part

    if dictionary.contains(combined):
      previous = combined
    else:
      if not inverted.hasKeyOrPut(previous, currentIndex):
        currentIndex = succ(currentIndex)
      result[0] = result[0] & inverted[previous]
      previous = part

  if not inverted.hasKeyOrPut(previous, currentIndex):
        currentIndex = succ(currentIndex)
  result[0] = result[0] & inverted[previous]

  # I want ot invert the table so it is keyed on the value
  # representing the data
  for k, v in inverted:
    result[1][v] = k

proc sendInput(intcode: var Program, input: string) =
  echo input
  for c in toSeq(input):
    intcode.resume(int64(ord(c)))
  intcode.resume(int64(10)) # add the newline

proc solution(grid: seq[seq[char]]): seq[(char, string)] =
  var
    pos:         Vector2D
    orientation: char
    visited:     HashSet[Vector2D]
    steps:       int
    rot:         char

  for y, row in grid:
    for x, cell in row:
      if cell == '>' or cell == '^' or cell == '<' or cell == 'v':
        pos = (x, y)
        orientation = cell

  while true:
    # mark this position as visited
    visited.incl(pos)

    # fetch neighbours upto 2 squares away
    var neighbours = neighbouring(grid, pos) - visited

    # prefer our current direction
    var nextPos: array[2, Vector2D]
    case orientation:
      of '>':
        nextPos[0] = (pos.x + 1, pos.y)
        nextPos[1] = (pos.x + 2, pos.y)
      of '<':
        nextPos[0] = (pos.x - 1, pos.y)
        nextPos[1] = (pos.x - 2, pos.y)
      of '^':
        nextPos[0] = (pos.x, pos.y - 1)
        nextPos[1] = (pos.x, pos.y - 2)
      else:
        nextPos[0] = (pos.x, pos.y + 1)
        nextPos[1] = (pos.x, pos.y + 2)

    if len(neighbours) == 0:
      result.add((rot, $steps))
      break

    # check if our current direction is a neighbour
    if neighbours.contains(nextPos[0]) or (neighbours.contains(nextPos[1]) and visited.contains(nextPos[0])):
      # so the prefferred direction is available so take it
      steps += 1
      pos = nextPos[0]
    else:
      # so we need to rotate so first commit the step count and
      # then we can reset it
      if steps > 0:
        result.add((rot, $steps))
        steps = 0

      # take any neighbour and rotate towards it
      let rotation = calculateRotation(orientation, pos, neighbours.pop())
      rot = rotation[0]
      orientation = rotation[1]

# challenge code here
# ===================
let file = open("./inputs/17.txt")

var input = strip(readAll(file)).split({ ',' }).mapIt(int64(parseInt(it)))
input[0] = int64(2)

var intcode = initProgram(input)
intcode.execute()

var
  output = intoGrid(intcode)
  path   = solution(output[0 .. high(output) - 3])
  compression = compress(path)
  progInputs = @[
    toSeq(compression[0]).join(","),
    compression[1]['A'],
    compression[1]['B'],
    compression[1]['C'],
    "n",
  ]
  i = low(progInputs)

while not intcode.halted:
  if i <= high(progInputs):
    sendInput(intcode, progInputs[i])
    i += 1

  handleOutput(intcode)
