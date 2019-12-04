// Day 4: Secure Container
// https://adventofcode.com/2019/day/4#part2

package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
)

// Oh golang. If only you had generics
type RuneSort []rune

func (s RuneSort) Less(i, j int) bool { return s[i] < s[j] }
func (s RuneSort) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s RuneSort) Len() int           { return len(s) }

func extractRange() (int, int) {
	f, _ := os.Open("./inputs/04.txt")
	defer f.Close()

	rdr := bufio.NewReader(f)

	// I'm being pointlessly strange here to avoid splitting the string
	// seeing as I know the size of the integers I can just extract the
	// exact bytes from the file
	aBuffer := make([]byte, 6)
	bBuffer := make([]byte, 6)

	io.ReadFull(rdr, aBuffer)
	rdr.Discard(1)
	io.ReadFull(rdr, bBuffer)

	a, _ := strconv.Atoi(string(aBuffer))
	b, _ := strconv.Atoi(string(bBuffer))
	return a, b
}

func isAscending(runes []rune) bool {
	return sort.IsSorted(RuneSort(runes))
}

func hasPair(runes []rune) bool {
	counts := make(map[rune]int)
	for _, r := range runes {
		counts[r] += 1
	}
	for _, count := range counts {
		if count == 2 {
			return true
		}
	}
	return false
}

func main() {
	a, b := extractRange()
	count := 0

	var current []rune

	for a <= b {
		current = []rune(strconv.Itoa(a))
		if isAscending(current) && hasPair(current) {
			count += 1
		}
		a += 1
	}

	fmt.Println(count)
}
