input = File.read('./inputs/02.txt').split(',').map(&:to_i)

pos = 0

input[1] = 12
input[2] = 2

loop do
  opcode = input[pos]
  if opcode == 1
    a, b = input[input[pos + 1]], input[input[pos + 2]]
    input[input[pos + 3]] = a + b
    pos += 4
    next
  elsif opcode == 2
    a, b = input[input[pos + 1]], input[input[pos + 2]]
    input[input[pos + 3]] = a * b
    pos += 4
  elsif opcode == 99
    break
  end
end

puts input[0]
