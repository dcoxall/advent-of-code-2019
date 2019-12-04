# Day 4: Secure Container
# https://adventofcode.com/2019/day/4

import algorithm, strutils, sequtils, tables

proc paired(nums: seq[char]): bool =
  let numCount = toCountTable(nums)
  result = false
  for _, count in numCount.pairs:
    if count > 1:
      result = true
      return

let
  input = open("./inputs/04.txt")
  vals  = input.readAll().split({ '-' }).mapIt(parseInt(strip(it)))
  a     = vals[0]
  b     = vals[1]

input.close()

var count = 0

for num in a..b:
  let parts = toSeq($num)
  if isSorted(parts) and paired(parts):
    count += 1

echo count
