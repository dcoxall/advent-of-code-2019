// Day 7: Amplification Circuit
// https://adventofcode.com/2019/day/7#part2

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
	input   <-chan int
	output  chan<- int
	memory  []int
	address int
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

func (prog *Intcode) Execute(wg *sync.WaitGroup) {
	defer wg.Done()
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

func publish(in <-chan int, outs ...chan<- int) {
	for val := range in {
		for _, out := range outs {
			out <- val
		}
	}
}

func notifyWhenDone(notify chan<- struct{}, wg *sync.WaitGroup) {
	wg.Wait()
	notify <- struct{}{}
}

func attempt(phases []int, memory []int) int {
	length := len(phases)
	amps := make([]*Intcode, length)
	inputs := make([]chan int, length)
	outputs := make([]chan int, length)

	for i, _ := range inputs {
		outputs[i] = make(chan int, 1)
		inputs[(i+1)%length] = outputs[i]
	}

	// create a channel that will push to multiple other channels
	// and plug it into the output of the last amp
	fanout := make(chan int, 1)
	// we also want a channel to subscribe to those values
	monitor := make(chan int, 1)
	outputs[length-1] = fanout
	go publish(fanout, inputs[0], monitor)

	wg := sync.WaitGroup{}

	for i, phase := range phases {
		mem := make([]int, len(memory))
		copy(mem, memory)
		amps[i] = NewIntcodeProg(mem, inputs[i], outputs[i])
		inputs[i] <- phase

		// start running the amp
		wg.Add(1)
		go amps[i].Execute(&wg)
	}

	// now we want to be notified when the result is sent
	// so that we can tidy up and continue so again we use
	// a channel to communicate this
	allDone := make(chan struct{}, 1)
	go notifyWhenDone(allDone, &wg)

	// everything is running now so seed the first
	// amp with the initial value
	inputs[0] <- 0

	for running := true; running; {
		select {
		case <-monitor:
			// we received a value from the monitor
			// we want to read it off to unblock the channel
		case <-allDone:
			// Close shop, we're finished
			close(fanout) // this will stop the fanout
			running = false
		}
	}

	// this leaves the last value as the correct value
	return <-monitor
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

	phases := []int{9, 8, 7, 6, 5}
	var highest int
	for p := make([]int, len(phases)); p[0] < len(p); nextPerm(p) {
		val := attempt(getPerm(phases, p), memory)
		if val > highest {
			highest = val
		}
	}

	fmt.Println(highest)
}
