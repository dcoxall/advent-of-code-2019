// Day 6: Universal Orbit Map
// https://adventofcode.com/2019/day/6#part2

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

	distanceFromYou := make(map[string]int, len(orbits))
	count := 0

	for planet, ok := orbits["YOU"]; ok; planet, ok = orbits[planet] {
		distanceFromYou[planet] = count
		count++
	}

	count = 0
	for planet, ok := orbits["SAN"]; ok; planet, ok = orbits[planet] {
		if distance, isCommon := distanceFromYou[planet]; isCommon {
			fmt.Println(distance + count)
			break
		}
		count++
	}
}
