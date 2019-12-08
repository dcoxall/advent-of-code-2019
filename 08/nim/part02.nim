# Day 8: Space Image Format
# https://adventofcode.com/2019/day/8#part2

import algorithm, strutils, sequtils

let
  input = open("./inputs/08.txt")
  width = 25
  height = 6

var
  flattened = newSeq[char](width * height)
  pixels = toSeq(strip(input.readAll()))

input.close()
fill(flattened, '2')

proc switchChar(c: char): string =
  result = " "
  if c == '1':
    result = "█"
  return

var offset = 0
while offset < len(pixels):
  let layer = pixels[offset..(offset + (width * height) - 1)]

  for i, c in layer:
    if flattened[i] == '2':
      flattened[i] = c

  offset += width * height

for h in 0..(height - 1):
  let row = flattened[(h * width)..((h * width) + width - 1)]
  echo foldl(row, a & switchChar(b), "")
