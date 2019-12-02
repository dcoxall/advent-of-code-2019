def attempt(noun, verb)
  input = File.read('./inputs/02.txt').split(',').map(&:to_i)
  pos = 0
  input[1] = noun
  input[2] = verb

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
  input[0]
end


catch(:quit) do
  (0..99).each do |noun|
    (0..99).each do |verb|
      if attempt(noun, verb) == 196_907_20
        puts 100 * noun + verb
        throw :quit
      end
    end
  end
end
