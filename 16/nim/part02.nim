# Day 16: Flawed Frequency Transmission
# https://adventofcode.com/2019/day/16#part2

import sequtils, strutils

let file = open("./inputs/16.txt")
var signal = cycle(toSeq(strip(readAll(file))).mapIt(parseInt($it)), 10_000)
let offset = parseInt(signal[0..6].join)

file.close()

for phase in (1..100):
  var part = signal[offset..high(signal)].foldl(a + b, 0)
  for i in offset..high(signal):
    let tmp = part
    part -= signal[i]
    signal[i] = abs(tmp) mod 10

echo signal[offset..(offset + 7)].join
