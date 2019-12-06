// Day 6: Universal Orbit Map
// https://adventofcode.com/2019/day/6

package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	f, _ := os.Open("./inputs/06.txt")
	defer f.Close()

	rdr := bufio.NewReader(f)
	scanner := bufio.NewScanner(rdr)
	orbits := make(map[string]string, 0)

	for scanner.Scan() {
		planets := strings.Split(scanner.Text(), ")")
		orbits[planets[1]] = planets[0]
	}

	count := 0
	for planet := range orbits {
		for planet, ok := orbits[planet]; ok; planet, ok = orbits[planet] {
			count++
		}
	}

	fmt.Println(count)
}
