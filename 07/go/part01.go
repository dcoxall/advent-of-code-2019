// Day 7: Amplification Circuit
// https://adventofcode.com/2019/day/7

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Intcode struct {
	memory  []int
	address int
	input   <-chan int
	output  chan<- int
	halted  bool
}

type Instruction struct {
	Opcode int
	Modes  []int
}

func NewIntcodeProg(memory []int, input <-chan int, output chan<- int) *Intcode {
	return &Intcode{
		memory:  memory,
		input:   input,
		output:  output,
		halted:  false,
		address: 0,
	}
}

func (prog *Intcode) Execute() {
	for !prog.halted {
		instruction := prog.parseInstruction(prog.memory[prog.address])
		prog.executeInstruction(instruction)
	}
}

func (prog *Intcode) opAdd(a, b, c int) {
	prog.memory[c] = a + b
	prog.address += 4
}

func (prog *Intcode) opMultiply(a, b, c int) {
	prog.memory[c] = a * b
	prog.address += 4
}

func (prog *Intcode) opInput(a int) {
	prog.memory[a] = <-prog.input
	prog.address += 2
}

func (prog *Intcode) opOutput(a int) {
	prog.output <- a
	prog.address += 2
}

func (prog *Intcode) opJmpTrue(a, b int) {
	if a != 0 {
		prog.address = b
	} else {
		prog.address += 3
	}
}

func (prog *Intcode) opJmpFalse(a, b int) {
	if a == 0 {
		prog.address = b
	} else {
		prog.address += 3
	}
}

func (prog *Intcode) opLessThan(a, b, c int) {
	if a < b {
		prog.memory[c] = 1
	} else {
		prog.memory[c] = 0
	}
	prog.address += 4
}

func (prog *Intcode) opEquals(a, b, c int) {
	if a == b {
		prog.memory[c] = 1
	} else {
		prog.memory[c] = 0
	}
	prog.address += 4
}

func (prog *Intcode) opHalt() {
	prog.address += 1
	prog.halted = true
	close(prog.output)
}

func (prog *Intcode) param(modes []int, n int) int {
	i := prog.memory[prog.address+n+1]
	if modes[n] == 0 {
		return prog.memory[i]
	} else {
		return i
	}
}

func (prog *Intcode) executeInstruction(inst *Instruction) {
	switch inst.Opcode {
	case 1:
		prog.opAdd(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.memory[prog.address+3],
		)
	case 2:
		prog.opMultiply(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.memory[prog.address+3],
		)
	case 3:
		prog.opInput(
			prog.memory[prog.address+1],
		)
	case 4:
		prog.opOutput(
			prog.param(inst.Modes, 0),
		)
	case 5:
		prog.opJmpTrue(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
		)
	case 6:
		prog.opJmpFalse(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
		)
	case 7:
		prog.opLessThan(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.memory[prog.address+3],
		)
	case 8:
		prog.opEquals(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.memory[prog.address+3],
		)
	case 99:
		prog.opHalt()
	}
}

func (prog *Intcode) parseInstruction(num int) *Instruction {
	digits := make([]int, 5)
	for i := 0; i < 5 && num > 0; i++ {
		digits[i] = num % 10
		num /= 10
	}
	opcode := digits[1]*10 + digits[0]
	return &Instruction{
		Opcode: opcode,
		Modes:  digits[2:],
	}
}

// The following two functions are taken from
// https://stackoverflow.com/questions/30226438/generate-all-permutations-in-go#30230552
func nextPerm(p []int) {
	for i := len(p) - 1; i >= 0; i-- {
		if i == 0 || p[i] < len(p)-i-1 {
			p[i]++
			return
		}
		p[i] = 0
	}
}

func getPerm(orig, p []int) []int {
	result := make([]int, len(orig))
	copy(result, orig)
	for i, v := range p {
		result[i], result[i+v] = result[i+v], result[i]
	}
	return result
}

func main() {
	f, _ := os.Open("./inputs/07.txt")
	defer f.Close()

	rdr := bufio.NewReader(f)
	scanner := bufio.NewScanner(rdr)
	memory := make([]int, 0)

	for scanner.Scan() {
		for _, num := range strings.Split(scanner.Text(), ",") {
			value, err := strconv.Atoi(num)
			if err != nil {
				fmt.Println(err)
			}
			memory = append(memory, value)
		}
	}

	results := make([]int, 0)
	phases := []int{0, 1, 2, 3, 4}
	for p := make([]int, len(phases)); p[0] < len(p); nextPerm(p) {
		input := make(chan int, 5)
		entry := input
		for _, phase := range getPerm(phases, p) {
			mem := make([]int, len(memory))
			copy(mem, memory)
			output := make(chan int, 5)
			input <- phase
			prog := NewIntcodeProg(mem, input, output)
			go prog.Execute()
			input = output
		}

		entry <- 0
		results = append(results, <-input)
	}

	var highest int
	for _, val := range results {
		if highest < val {
			highest = val
		}
	}

	fmt.Println(highest)
}
