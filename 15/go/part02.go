// Day 15: Oxygen System
// https://adventofcode.com/2019/day/15#part2

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
	DirNorth int64 = iota + 1
	DirSouth
	DirWest
	DirEast
)

const (
	StatusWall int64 = iota
	StatusOk
	StatusOxygen
	StatusSelf
)

func draw(canvas map[Point]int64, curr Point) {
	// there has to be a nicer way but... meh this will do
	minWidth := 0
	maxWidth := 0
	minHeight := 0
	maxHeight := 0

	for point, _ := range canvas {
		if point.X > maxWidth {
			maxWidth = point.X
		}
		if point.X < minWidth {
			minWidth = point.X
		}
		if point.Y > maxHeight {
			maxHeight = point.Y
		}
		if point.Y < minHeight {
			minHeight = point.Y
		}
	}

	// now I need to know what value to translate all the points to keep them
	// within my boundaries
	translateX := minWidth * -1
	translateY := minHeight * -1

	pixels := make([]int64, (maxHeight+translateY+1)*(maxWidth+translateX+1))
	for point, val := range canvas {
		x := point.X + translateX
		y := point.Y + translateY
		if point == curr {
			pixels[(y*(maxWidth+translateX))+x] = StatusSelf
		} else {
			pixels[(y*(maxWidth+translateX))+x] = val
		}
	}

	// fmt.Println("\033[H\033[2J")

	for y := 0; y <= maxHeight+translateY; y++ {
		var sb strings.Builder
		row := pixels[y*(maxWidth+translateX) : (y*(maxWidth+translateX))+maxWidth+translateX]
		for _, val := range row {
			switch val {
			case StatusSelf:
				sb.WriteString("D")
			case StatusWall:
				sb.WriteString(" ")
			case StatusOxygen:
				sb.WriteString("O")
			default:
				sb.WriteString("█")
			}
		}
		fmt.Println(sb.String())
	}
}

func adjacent(p Point) []Point {
	return []Point{
		Point{p.X, p.Y - 1}, // North
		Point{p.X, p.Y + 1}, // South
		Point{p.X + 1, p.Y}, // East
		Point{p.X - 1, p.Y}, // West
	}
}

func findPreviousUsableSpace(path []Point, curr Point) (int64, Point) {
	for i := 1; i <= len(path); i++ {
		point := path[len(path)-i]
		if point.Y == curr.Y-1 && curr.X == point.X {
			return DirNorth, point
		}
		if point.Y == curr.Y+1 && curr.X == point.X {
			return DirSouth, point
		}
		if point.X == curr.X+1 && curr.Y == point.Y {
			return DirEast, point
		}
		if point.X == curr.X-1 && curr.Y == point.Y {
			return DirWest, point
		}
	}

	panic("WTF")
}

// needs to return a direction
func navigateTo(path []Point, curr Point, target Point) (int64, Point) {
	if target.Y == curr.Y-1 && curr.X == target.X {
		return DirNorth, target
	}
	if target.Y == curr.Y+1 && curr.X == target.X {
		return DirSouth, target
	}
	if target.X == curr.X+1 && curr.Y == target.Y {
		return DirEast, target
	}
	if target.X == curr.X-1 && curr.Y == target.Y {
		return DirWest, target
	}

	return findPreviousUsableSpace(path, curr)
}

func main() {
	f, _ := os.Open("./inputs/15.txt")
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

	intcode := NewIntcodeProg(memory)
	canvas := make(map[Point]int64)
	currentPath := make([]Point, 0)
	currentPos := Point{0, 0}
	canvas[currentPos] = StatusOk

	stack := make([]Point, 0)
	stack = append(stack, adjacent(currentPos)...)
	currentPath = append(currentPath, currentPos)
	maxPath := 0

	intcode.Execute()

	for target := stack[len(stack)-1]; len(stack) > 1; target = stack[len(stack)-1] {
		// whilst we have a target we need to determine if we have been there
		// yet or not.

		// If we have already visited it then we can remove it from the stack
		// and then continue
		if _, visited := canvas[target]; visited {
			stack = stack[:len(stack)-1]
			continue
		}

		// so we havent yet been there so let's work out how to get there
		dir, actualTarget := navigateTo(currentPath, currentPos, target)
		intcode.ResumeWith(dir)

		// Now we will have some output to tell us the response
		if hasOutput, status := intcode.ReadOutput(); hasOutput {
			canvas[actualTarget] = status

			if status != StatusWall {
				// the last move was a success so update our position
				currentPos = actualTarget

				if actualTarget == target {
					// and add further points to the stack to explore
					stack = append(stack, adjacent(target)...)
					currentPath = append(currentPath, target)
					if tmpMax := len(currentPath); tmpMax > maxPath {
						maxPath = tmpMax
					}

					if status == StatusOxygen {
						// we want to forget everything else and begin tracking the max path length
						currentPath = currentPath[:0]
						maxPath = 0
						canvas = make(map[Point]int64)
						canvas[target] = StatusOxygen
					}
				} else {
					// not a new position so we remove it from our path
					currentPath = currentPath[:len(currentPath)-1]
				}
			}
		}
	}

	draw(canvas, currentPos)
	fmt.Println(maxPath)
}
