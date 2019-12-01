package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func fuelRequirement(mass int) int {
	if mass := (mass / 3) - 2; mass > 0 {
		return mass + fuelRequirement(mass)
	}
	return 0
}

func main() {
	f, _ := os.Open("./inputs/01.txt")
	defer f.Close()

	var (
		total      int
		moduleMass int
	)

	rdr := bufio.NewReader(f)
	for {
		line, err := rdr.ReadString('\n')
		if err != nil {
			break
		}
		moduleMass, _ = strconv.Atoi(line[:len(line)-1])
		total += fuelRequirement(moduleMass)
	}

	fmt.Println(total)
}
