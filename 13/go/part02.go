// Day 13: Care Package
// https://adventofcode.com/2019/day/13#part2

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Intcode struct {
	memory       map[int64]int64
	address      int64
	halted       bool
	relativeBase int64
	paused       bool
	inputs       []int64
	outputs      []int64
}

type Instruction struct {
	Opcode int64
	Modes  []int64
}

func NewIntcodeProg(memory []int64) *Intcode {
	mem := make(map[int64]int64, len(memory))

	for i, n := range memory {
		mem[int64(i)] = n
	}

	return &Intcode{
		memory:  mem,
		halted:  false,
		paused:  false,
		outputs: make([]int64, 0),
		inputs:  make([]int64, 0),
	}
}

func (prog *Intcode) Execute() {
	for !prog.halted && !prog.paused {
		instruction := prog.parseInstruction(prog.memory[prog.address])
		prog.executeInstruction(instruction)
	}
}

func (prog *Intcode) ResumeWith(vals ...int64) {
	prog.inputs = append(prog.inputs, vals...)
	prog.paused = false
	prog.Execute()
}

func (prog *Intcode) ReadOutput() (bool, int64) {
	if len(prog.outputs) > 0 {
		val := prog.outputs[0]
		prog.outputs = prog.outputs[1:]
		return true, val
	}
	return false, 0
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
	if len(prog.inputs) == 0 {
		prog.paused = true
	} else {
		prog.memory[a] = prog.inputs[0]
		prog.inputs = prog.inputs[1:]
		prog.address += 2
	}
}

func (prog *Intcode) opOutput(a int64) {
	prog.outputs = append(prog.outputs, prog.memory[a])
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

type Point struct {
	X int
	Y int
}

const (
	IdPaddle = int64(3)
	IdBall   = int64(4)
)

func cmp(a, b int) int {
	if a > b {
		return 1
	}
	if a < b {
		return -1
	}
	return 0
}

func readGameData(game *Intcode) (bool, Point, int64) {
	var (
		ok        bool
		x, y, val int64
	)
	if ok, x = game.ReadOutput(); !ok {
		return false, Point{0, 0}, 0
	}
	if ok, y = game.ReadOutput(); !ok {
		return false, Point{0, 0}, 0
	}
	if ok, val = game.ReadOutput(); !ok {
		return false, Point{0, 0}, 0
	}
	point := Point{X: int(x), Y: int(y)}
	return true, point, val
}

func main() {
	f, _ := os.Open("./inputs/13.txt")
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

	memory[int64(0)] = 2

	intcode := NewIntcodeProg(memory)
	canvas := make(map[Point]int64)
	var (
		ball   Point
		paddle Point
		score  int64
	)

	intcode.Execute()

	for !intcode.halted {
		// read the outputs
		for ok, point, val := readGameData(intcode); ok; ok, point, val = readGameData(intcode) {
			if point.X == -1 {
				score = val
			} else {
				switch val {
				case IdBall:
					ball = point
				case IdPaddle:
					paddle = point
				}
				canvas[point] = val
			}
		}

		// handle inputs
		intcode.ResumeWith(int64(cmp(ball.X, paddle.X)))
	}

	for ok, point, val := readGameData(intcode); ok; ok, point, val = readGameData(intcode) {
		if point.X == -1 {
			score = val
		}
	}

	fmt.Println(score)
}
