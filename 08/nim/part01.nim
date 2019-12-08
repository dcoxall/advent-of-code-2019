# Day 8: Space Image Format
# https://adventofcode.com/2019/day/8

import strutils, sequtils

let
  input = open("./inputs/08.txt")
  width = 25
  height = 6

var
  pixels = toSeq(strip(input.readAll()))
  zeroCount = -1
  selectedOffset = 0

input.close()

var offset = 0
while offset < len(pixels):
  let
    layer = pixels[offset..(offset + (width * height) - 1)]
    localCount = count(layer, '0')

  if zeroCount < 0:
    zeroCount = localCount

  if localCount < zeroCount:
    zeroCount = localCount
    selectedOffset = offset

  offset += width * height

let layer = pixels[selectedOffset..(selectedOffset + (width * height) - 1)]
echo count(layer, '1') * count(layer, '2')
