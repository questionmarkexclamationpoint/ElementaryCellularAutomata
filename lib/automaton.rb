require_relative 'bit_array'

class Automaton
  attr_reader :array

  def initialize(rule: 0, neighbors: 3, size: 256, randomize: true, value: (rand(1 << size)))
      @array = BitArray.new(size, value)
      self.neighbors = neighbors
      self.rule = rule
  end

  def step(n = 1)
    return to_enum(:step, n) unless block_given?
    n.times do
      new_arr = BitArray.new(@array.size)
      b = neighbors
      new_indices = Array.new(b, 0)
      (b - 1).times do |i|
        (0..i).each do |j|
          new_indices[j] <<= 1
          new_indices[j] += @array[@array.size - (b - i) + 1]
        end
      end
      @array.each.with_index do |bit, i|
        new_indices.size.times do |j|
          new_indices[j] <<= 1
          new_indices[j] += bit
        end
        new_arr[(i - 1) % new_arr.size] = @rule[new_indices[i % new_indices.size]]
        new_indices[i % new_indices.size] = 0
      end
      @array = new_arr
      yield @array
    end
  end

  def print
    puts @array.map{|v| v == 1 ? '█' : ' '}.join('')
  end

  def rule
    @rule.val
  end

  def rule=(n)
      @rule = BitArray.new(2 << neighbors, n)
  end

  def neighbors
      @upper + @lower + 1
  end

  def neighbors=(n)
      @lower = n / 2
      @upper = n - 1 - @lower
      new_rule = BitArray.new
      @rule.to_a.reverse.each.with_index{ |v, i| new_rule[-i] = v }
      @rule = new_rule
      n
  end

  def randomize
    @array = BitArray.new(@array.size, rand(1 << @array.size))
  end
end