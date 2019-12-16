# Day 16: Flawed Frequency Transmission
# https://adventofcode.com/2019/day/16

import sequtils, strutils

let
  file    = open("./inputs/16.txt")
  pattern = @[0, 1, 0, -1]
  length  = len(pattern)

var
  signal = toSeq(strip(readAll(file))).mapIt(parseInt($it))
  output = newSeq[int](len(signal))

file.close()

for phase in (1..100):
  for i in (low(output)..high(output)):
    var acc = 0
    for j in (low(output)..high(output)):
      acc += signal[j] * pattern[((j + 1) div (i + 1)) mod length]
    output[i] = abs(acc) mod 10
  signal = output

echo signal[0..7].join
