# Day 9: Sensor Boost
# https://adventofcode.com/2019/day/9

class Intcode
  OPCODES = {
    # code => [func, read_param_count, write_param_count]
    1  => [:add, 2, 1],
    2  => [:multiply, 2, 1],
    3  => [:store, 0, 1],
    4  => [:output, 1, 0],
    5  => [:jump_if_true, 2, 0],
    6  => [:jump_if_false, 2, 0],
    7  => [:less_than, 2, 1],
    8  => [:equals, 2, 1],
    9  => [:adjust_base_offset, 1, 0],
    99 => [:halt, 0, 0],
  }.freeze

  def initialize(memory, input, silent: false)
    @mem = Hash.new { |h, k| h[k] = 0 }
    memory.each_with_index do |n, i|
      @mem[i] = n.to_i
    end
    @input   = input.reverse.map(&:to_i)
    @address = 0
    @outputs = []
    @halt    = false
    @silent  = silent
    @relative_base = 0
  end

  def execute!
    while !@halt
      opcode, modes = parse_instruction(@mem[@address])
      op, read_arity, write_arity = OPCODES[opcode]

      read_params = read_arity.times.map { |i| get(i, modes[i]) }
      write_params = write_arity.times.map { |i| get(i + read_arity, modes[i + read_arity]) }

      send(op, *read_params, *write_params)
    end
    @outputs
  end

  private

  # opcode: 1
  def add(a, b, c)
    @mem[c] = @mem[a] + @mem[b]
    @address += 4
  end

  # opcode: 2
  def multiply(a, b, c)
    @mem[c] = @mem[a] * @mem[b]
    @address += 4
  end

  # opcode: 3
  def store(a)
    @mem[a] = @input.pop
    @address += 2
  end

  # opcode: 4
  def output(a)
    puts @mem[a] if !@silent
    @outputs << @mem[a]
    @address += 2
  end

  # opcode: 5
  def jump_if_true(a, b)
    @address = @mem[b] and return if @mem[a] != 0
    @address += 3
  end

  # opcode: 6
  def jump_if_false(a, b)
    @address = @mem[b] and return if @mem[a] == 0
    @address += 3
  end

  # opcode: 7
  def less_than(a, b, c)
    @mem[c] = @mem[a] < @mem[b] ? 1 : 0
    @address += 4
  end

  # opcode: 8
  def equals(a, b, c)
    @mem[c] = @mem[a] == @mem[b] ? 1 : 0
    @address += 4
  end

  # opcode: 9
  def adjust_base_offset(a)
    @relative_base += @mem[a]
    @address += 2
  end

  # opcode: 99
  def halt
    @halt = true
  end

  def parse_instruction(instruction)
    digits = instruction.digits
    opcode = ((digits[1] || 0) * 10) + digits[0]
    [opcode, digits[2..-1] || []]
  end

  def get(i, mode)
    case mode
    when nil, 0 then @mem[@address + 1 + i]
    when 1 then @address + 1 + i
    when 2 then @mem[@address + 1 + i] + @relative_base
    else
      raise ArgumentError, "WTF"
    end
  end
end


input = File.read('./inputs/09.txt').split(',')
program = Intcode.new(input, [1])
program.execute!
