class Intcode
  OPCODES = {
    1  => [:add, 3],
    2  => [:multiply, 3],
    3  => [:store, 1],
    4  => [:output, 1],
    5  => [:jump_if_true, 2],
    6  => [:jump_if_false, 2],
    7  => [:less_than, 3],
    8  => [:equals, 3],
    99 => [:halt, 0],
  }.freeze

  def initialize(memory, input, silent: false)
    @mem     = memory.map(&:to_i)
    @input   = input.reverse.map(&:to_i)
    @address = 0
    @outputs = []
    @halt    = false
    @silent  = silent
  end

  def execute!
    while !@halt
      opcode, modes = parse_instruction(@mem[@address])
      op, arity = OPCODES[opcode]
      params = @mem[@address + 1, arity]
      send(op, modes, *params)
    end
    @outputs
  end

  private

  # opcode: 1
  def add(m, a, b, c)
    @mem[c] = get(m[0], a) + get(m[1], b)
    @address += 4
  end

  # opcode: 2
  def multiply(m, a, b, c)
    @mem[c] =  get(m[0], a) * get(m[1], b)
    @address += 4
  end

  # opcode: 3
  def store(m, a)
    @mem[a] = @input.pop
    @address += 2
  end

  # opcode: 4
  def output(m, a)
    val = get(m[0], a)
    puts val if !@silent
    @outputs << val
    @address += 2
  end

  # opcode: 5
  def jump_if_true(m, a, b)
    @address = get(m[1], b) and return if get(m[0], a) != 0
    @address += 3
  end

  # opcode: 6
  def jump_if_false(m, a, b)
    @address = get(m[1], b) and return if get(m[0], a) == 0
    @address += 3
  end

  # opcode: 7
  def less_than(m, a, b, c)
    @mem[c] = get(m[0], a) < get(m[1], b) ? 1 : 0
    @address += 4
  end

  # opcode: 8
  def equals(m, a, b, c)
    @mem[c] = get(m[0], a) == get(m[1], b) ? 1 : 0
    @address += 4
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


input = File.read('./inputs/07.txt').split(',')

highest_output = 0
best_order = []
[1,0,4,3,2].permutation.each do |phases|
  latest, *_ = phases.reduce([0]) do |prev_out, phase_setting|
    program = Intcode.new(input, [phase_setting, prev_out.last], silent: true)
    program.execute!
  end

  if latest > highest_output
    highest_output = latest
    best_order = phases
  end
end

puts highest_output
