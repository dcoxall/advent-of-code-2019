// Day 9: Sensor Boost
// https://adventofcode.com/2019/day/9

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
)

type Intcode struct {
	memory       map[int64]int64
	address      int64
	input        <-chan int64
	output       chan<- int64
	halted       bool
	relativeBase int64
}

type Instruction struct {
	Opcode int64
	Modes  []int64
}

func NewIntcodeProg(memory []int64, input <-chan int64, output chan<- int64) *Intcode {
	mem := make(map[int64]int64, len(memory))

	for i, n := range memory {
		mem[int64(i)] = n
	}

	return &Intcode{
		memory: mem,
		input:  input,
		output: output,
		halted: false,
	}
}

func (prog *Intcode) Execute(wg *sync.WaitGroup) {
	defer wg.Done()
	for !prog.halted {
		instruction := prog.parseInstruction(prog.memory[prog.address])
		prog.executeInstruction(instruction)
	}
}

func (prog *Intcode) opAdd(a, b, c int64) {
	prog.memory[c] = prog.memory[a] + prog.memory[b]
	prog.address += 4
}

func (prog *Intcode) opMultiply(a, b, c int64) {
	prog.memory[c] = prog.memory[a] * prog.memory[b]
	prog.address += 4
}

func (prog *Intcode) opInput(a int64) {
	prog.memory[a] = <-prog.input
	prog.address += 2
}

func (prog *Intcode) opOutput(a int64) {
	prog.output <- prog.memory[a]
	prog.address += 2
}

func (prog *Intcode) opJmpTrue(a, b int64) {
	if prog.memory[a] != 0 {
		prog.address = prog.memory[b]
	} else {
		prog.address += 3
	}
}

func (prog *Intcode) opJmpFalse(a, b int64) {
	if prog.memory[a] == 0 {
		prog.address = prog.memory[b]
	} else {
		prog.address += 3
	}
}

func (prog *Intcode) opLessThan(a, b, c int64) {
	if prog.memory[a] < prog.memory[b] {
		prog.memory[c] = 1
	} else {
		prog.memory[c] = 0
	}
	prog.address += 4
}

func (prog *Intcode) opEquals(a, b, c int64) {
	if prog.memory[a] == prog.memory[b] {
		prog.memory[c] = 1
	} else {
		prog.memory[c] = 0
	}
	prog.address += 4
}

func (prog *Intcode) opAdjustBaseOffset(a int64) {
	prog.relativeBase += prog.memory[a]
	prog.address += 2
}

func (prog *Intcode) opHalt() {
	prog.address += 1
	prog.halted = true
}

func (prog *Intcode) param(modes []int64, n int64) (res int64) {
	switch modes[n] {
	case 0:
		res = prog.memory[prog.address+n+1]
	case 1:
		res = prog.address + n + 1
	case 2:
		res = prog.memory[prog.address+n+1] + prog.relativeBase
	}
	return
}

func (prog *Intcode) executeInstruction(inst *Instruction) {
	switch inst.Opcode {
	case 1:
		prog.opAdd(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.param(inst.Modes, 2),
		)
	case 2:
		prog.opMultiply(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.param(inst.Modes, 2),
		)
	case 3:
		prog.opInput(
			prog.param(inst.Modes, 0),
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
			prog.param(inst.Modes, 2),
		)
	case 8:
		prog.opEquals(
			prog.param(inst.Modes, 0),
			prog.param(inst.Modes, 1),
			prog.param(inst.Modes, 2),
		)
	case 9:
		prog.opAdjustBaseOffset(
			prog.param(inst.Modes, 0),
		)
	case 99:
		prog.opHalt()
	}
}

func (prog *Intcode) parseInstruction(num int64) *Instruction {
	digits := make([]int64, 5)
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

func main() {
	f, _ := os.Open("./inputs/09.txt")
	defer f.Close()

	rdr := bufio.NewReader(f)
	scanner := bufio.NewScanner(rdr)
	memory := make([]int64, 0)

	for scanner.Scan() {
		for _, num := range strings.Split(scanner.Text(), ",") {
			value, err := strconv.ParseInt(num, 10, 64)
			if err != nil {
				fmt.Println(err)
			}
			memory = append(memory, value)
		}
	}

	input := make(chan int64)
	output := make(chan int64, 50)

	wg := sync.WaitGroup{}
	intcode := NewIntcodeProg(memory, input, output)
	wg.Add(1)
	go intcode.Execute(&wg)

	input <- int64(1)

	wg.Wait()

	close(input)
	close(output)

	fmt.Println(<-output)
}
