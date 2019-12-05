# Day 5: Sunny with a Chance of Asteroids
# https://adventofcode.com/2019/day/5

class Intcode
  OPCODES = {
    1  => [:add, 3],
    2  => [:multiply, 3],
    3  => [:store, 1],
    4  => [:output, 1],
    99 => [:halt, 0],
  }.freeze

  def initialize(memory, input)
    @mem     = memory.map(&:to_i)
    @input   = input.reverse.map(&:to_i)
    @address = 0
    @halt    = false
  end

  def execute!
    while !@halt
      opcode, modes = parse_instruction(@mem[@address])
      op, arity = OPCODES[opcode]
      params = @mem[@address + 1, arity]
      send(op, modes, *params)
      @address += arity + 1
    end
  end

  private

  # opcode: 1
  def add(m, a, b, c)
    @mem[c] = get(m[0], a) + get(m[1], b)
  end

  # opcode: 2
  def multiply(m, a, b, c)
    @mem[c] =  get(m[0], a) * get(m[1], b)
  end

  # opcode: 3
  def store(m, a)
    @mem[a] = @input.pop
  end

  # opcode: 4
  def output(m, a)
    puts get(m[0], a)
  end

  # opcode: 99
  def halt(m)
    @halt = true
  end

  def parse_instruction(instruction)
    digits = instruction.digits
    opcode = ((digits[1] || 0) * 10) + digits[0]
    [opcode, digits[2..-1] || []]
  end

  def get(mode, n)
    return @mem[n] if mode.nil? || mode.zero?
    n
  end
end


input = File.read('./inputs/05.txt').split(',')
program = Intcode.new(input, [1])
program.execute!
