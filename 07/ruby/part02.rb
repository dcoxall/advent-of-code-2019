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

  attr_reader :outputs

  def initialize(memory, input, silent: false)
    @mem     = memory.map(&:to_i)
    @input   = input.reverse.map(&:to_i)
    @address = 0
    @outputs = []
    @halt    = false
    @silent  = silent
    @paused  = false
  end

  def resume_with(*vals)
    @input.push(*vals)
    @paused = false
    execute!
  end

  def paused?
    @paused
  end

  def halted?
    @halt
  end

  def execute!
    while !halted? && !paused?
      opcode, modes = parse_instruction(@mem[@address])
      op, arity = OPCODES[opcode]
      params = @mem[@address + 1, arity]
      send(op, modes, *params)
    end
    self
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
    if @input.empty?
      # no input so pause
      @paused = true
      return
    end

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

def attempt(input, phase_settings)
  # start 5 amps, they will each pause on their first input
  amps = phase_settings.map do |phase_setting|
    i = Intcode.new(input, [phase_setting], silent: true)
    i.execute!
  end

  # seed the first amp with 0
  amps[0].resume_with(0)

  while !amps.last.halted?
    amps.each_with_index do |amp, i|
      next if amp.halted?
      out = amps[(i - 1) % 5].outputs.last
      next if out.nil?
      amp.resume_with(out)
    end
  end

  amps.last.outputs.last
end

highest_output = 0
best_order = []
[9,8,7,6,5].permutation.each do |phases|
  latest = attempt(input, phases)

  if latest > highest_output
    highest_output = latest
    best_order = phases
  end
end

puts highest_output
