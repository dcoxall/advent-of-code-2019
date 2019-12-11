// Day 11: Space Police
// https://adventofcode.com/2019/day/11#part2

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

func notifyWhenDone(notify chan<- struct{}, wg *sync.WaitGroup) {
	wg.Wait()
	notify <- struct{}{}
}

type Point struct {
	X int
	Y int
}

func draw(canvas map[Point]int64) {
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
		pixels[(y*(maxWidth+translateX))+x] = val
	}

	for y := 0; y <= maxHeight+translateY; y++ {
		var sb strings.Builder
		row := pixels[y*(maxWidth+translateX) : (y*(maxWidth+translateX))+maxWidth+translateX]
		for _, val := range row {
			if val == int64(1) {
				sb.WriteString("█")
			} else {
				sb.WriteString(" ")
			}
		}
		fmt.Println(sb.String())
	}
}

func main() {
	f, _ := os.Open("./inputs/11.txt")
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

	input := make(chan int64, 50)
	output := make(chan int64, 50)

	wg := sync.WaitGroup{}
	intcode := NewIntcodeProg(memory, input, output)
	wg.Add(1)
	go intcode.Execute(&wg)

	done := make(chan struct{})
	go notifyWhenDone(done, &wg)

	canvas := make(map[Point]int64)
	current := Point{0, 0}
	canvas[current] = 1
	dir := complex(float32(0), float32(-1))

	for running := true; running; {
		select {
		case <-done:
			running = false
		default:
			// provide the intcode machine with the color of our current square
			input <- canvas[current]
			// take the color output by the intcode process and apply it to our current
			// position
			canvas[current] = <-output
			if instruction := <-output; int(instruction) == 0 {
				dir *= complex(0, -1)
			} else {
				dir *= complex(0, 1)
			}

			// move in the current direction
			current = Point{current.X + int(real(dir)), current.Y + int(imag(dir))}
		}
	}

	close(input)
	close(output)

	draw(canvas)
}
