package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

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
		total += (moduleMass / 3) - 2
	}

	fmt.Println(total)
}
