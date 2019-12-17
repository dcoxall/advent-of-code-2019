# Day 17: Set and Forget
# https://adventofcode.com/2019/day/17

import tables, math, sequtils, strutils, os

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

proc intoGrid(intcode: var Program): seq[seq[char]] =
  let output = toSeq(intcode).foldl(a & char(int(b)), "")
  result = output.split({ '\n' }).mapIt(toSeq(it))

proc locatePoints(grid: seq[seq[char]]): seq[Vector2D] =
  for y, row in grid:
    for x, cell in row:
      if y == low(grid) or x == low(row) or y == high(grid) or x == high(row):
        continue

      let vals = (cell, grid[y - 1][x], grid[y + 1][x], grid[y][x - 1], grid[y][x + 1])

      if vals == ('#', '#', '#', '#', '#'):
        result.add((x, y))

# challenge code here
# ===================
let file = open("./inputs/17.txt")

var
  input   = strip(readAll(file)).split({ ',' }).mapIt(int64(parseInt(it)))
  intcode = initProgram(input)

intcode.execute()

let output = intoGrid(intcode)

# the output has 2 blank lines at the bottom so I just exclude them here
# as it lets me use more rational location logic
echo locatePoints(output[0 .. (high(output) - 2)]).foldl(a + b.x * b.y, 0)
