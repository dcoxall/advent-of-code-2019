// Day 5: Sunny with a Chance of Asteroids
// https://adventofcode.com/2019/day/5

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

type Intcode struct {
	memory  []int
	address int
	input   []int
	halted  bool
}

type Instruction struct {
	Opcode int
	Modes  []int
}

func NewIntcodeProg(memory []int, input []int) *Intcode {
	return &Intcode {
		memory:  memory,
		input:   input,
		halted:  false,
		address: 0,
	}
}

func (prog *Intcode) Execute() {
	for !prog.halted {
		instruction := parseInstruction(prog.memory[prog.address])
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
	prog.memory[a] = prog.input[0]
	prog.input = prog.input[1:]
	prog.address += 2
}

func (prog *Intcode) opOutput(a int) {
	fmt.Println(a)
	prog.address += 2
}

func (prog *Intcode) opHalt() {
	prog.address += 1
	prog.halted = true
}

func (prog *Intcode) param(mode, n int) int {
	if mode == 0 {
		return prog.memory[n]
	} else {
		return n
	}
}

func (prog *Intcode) executeInstruction(inst *Instruction) {
	switch inst.Opcode {
	case 1:
		prog.opAdd(
			prog.param(inst.Modes[0], prog.memory[prog.address + 1]),
			prog.param(inst.Modes[1], prog.memory[prog.address + 2]),
			prog.memory[prog.address + 3],
		)
	case 2:
		prog.opMultiply(
			prog.param(inst.Modes[0], prog.memory[prog.address + 1]),
			prog.param(inst.Modes[1], prog.memory[prog.address + 2]),
			prog.memory[prog.address + 3],
		)
	case 3:
		prog.opInput(prog.memory[prog.address + 1])
	case 4:
		prog.opOutput(
			prog.param(inst.Modes[0], prog.memory[prog.address + 1]),
		)
	case 99:
		prog.opHalt()
	}
}

func parseInstruction(num int) *Instruction {
	digits := make([]int, 5)
	for i := 0; i < 5 && num > 0; i++ {
		digits[i] = num % 10
		num /= 10
	}
	opcode := digits[1] * 10 + digits[0]
	return &Instruction {
		Opcode: opcode,
		Modes:  digits[2:],
	}
}

func main() {
	f, _ := os.Open("./inputs/05.txt")
	defer f.Close()

	rdr := bufio.NewReader(f)
	memory := make([]int, 0)
	for {
		num, err := rdr.ReadString(',')
		if err != nil {
			break
		}
		value, _ := strconv.Atoi(num[:len(num)-1])
		memory = append(memory, value)
	}

	program := NewIntcodeProg(memory, []int{ 1 })
	program.Execute()
}
