import strutils, sequtils

let file = open("./inputs/02.txt")
var input = readAll(file).split({ ',' }).mapIt(parseInt(strip(it)))
file.close()

input[1] = 12
input[2] = 2

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

echo input[0]
