import strutils, sequtils

proc execute(orig: seq[int], noun: int, verb: int): int =
  # reading the file each time is slow so we instead want
  # to read the file once and then copy the data whenever
  # we want to try a new variant
  var input: seq[int]
  deepCopy(input, orig)

  input[1] = noun
  input[2] = verb

  var
    pos     = 0
    halted  = false
    opcode  = input[0]

  while not halted:
    if opcode == 1:
      input[input[pos + 3]] = input[input[pos + 1]] + input[input[pos + 2]]
      pos += 4

    if opcode == 2:
      input[input[pos + 3]] = input[input[pos + 1]] * input[input[pos + 2]]
      pos += 4

    if opcode == 99:
      halted = true

    opcode = input[pos]
    result = input[0]

let file = open("./inputs/02.txt")
var input = readAll(file).split({ ',' }).mapIt(parseInt(strip(it)))
file.close()

block calculations:
  for noun in 0..99:
    for verb in 0..99:
      if execute(input, noun, verb) == 19_690_720:
        echo 100 * noun + verb
        break calculations

