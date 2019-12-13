# Day 13: Care Package
# https://adventofcode.com/2019/day/13

import tables, math, sequtils, strutils

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

  UnknownGrid = Table[Vector2D, int]

  Grid = tuple
    width, height: int
    vals: seq[int]

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
  if prog.memory[a] == 0:
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

proc `[]=` (g: var UnknownGrid, k: Vector2D, v: int) =
  g.add(k, v)

proc intoGrid(grid: UnknownGrid): Grid =
  var
    widths  = (0, 0) # min width and max width
    heights = (0, 0) # min height and max height

  for vec in grid.keys:
    widths[0]  = min(widths[0], vec.x)
    widths[1]  = max(widths[1], vec.x)
    heights[0] = min(heights[0], vec.y)
    heights[1] = max(heights[1], vec.y)

  let translation: Vector2D = (widths[0] * -1, heights[0] * -1)

  result.width  = widths[1] + translation.x + 1
  result.height = heights[1] + translation.y + 1
  result.vals   = newSeq[int](result.width * result.height)

  for vec, n in grid:
    let
      x = vec.x + translation.x
      y = vec.y + translation.y

    result.vals[(y * result.width) + x] = n

proc cellToString(n: int): string =
  case n:
  of 1:
    result = "+"
  of 2:
    result = "█"
  of 3:
    result = "-"
  else:
    result = " "


proc drawGrid(grid: Grid) =
  var y = 0
  while y < grid.height:
    let
      start  = y * grid.width
      finish = start + grid.width - 1

    y += 1

    echo grid.vals[start .. finish].foldl(a & cellToString(b), "")

# challenge code here
# ===================
let file = open("./inputs/13.txt")

var
  canvas: UnknownGrid

  input = strip(readAll(file)).split({ ',' }).mapIt(int64(parseInt(it)))
  intcode = initProgram(input)

intcode.execute()

let output = toSeq(intcode)

var
  i     = 0
  count = 0

while i < high(output):
  let
    vector: Vector2D = (int(output[i]), int(output[i + 1]))
    value = int(output[i + 2])

  canvas[vector] = value

  if value == 2:
    count += 1

  i += 3

drawGrid(intoGrid(canvas))

echo ""
echo count
