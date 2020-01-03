class BitArray
  attr_reader :value, :size
  include Enumerable
  def initialize(size = 8, val = 0)
    @size = size
    @valid_indices = (0..size - 1)
    @ones = (1 << size) - 1
    @value = val & @ones
  end
  
  def [](i)
    raise IndexError.new("#{ i } out of bounds") unless @valid_indices.include?(i)
    (@value >> i) & 1
  end
  
  def []=(i, n)
    raise IndexError.new("#{ i } out of bounds") unless @valid_indices.include?(i)
    raise ArgumentError.new("#{ n } not a valid value") unless n == 1 || n == 0
    if n == 0
      @value &= ~(1 << i)
    else
      @value |= (1 << i)
    end
    n
  end
  
  def each
    return to_enum unless block_given?
    tmp = @value
    @size.times do
      yield tmp & 1
      tmp >>= 1
    end
    self
  end
  
  def ==(other)
    other.is_a?(BitArray) && @value == other.value && @size == other.size
  end
  
  def &(other)
    binary_bitwise_operation(other, :&)
  end
  
  def |(other)
    binary_bitwise_operation(other, :|)
  end
  
  def ^(other)
    binary_bitwise_operation(other, :^)
  end
  
  def ~
    @value ^ @ones
  end
  
  private
  
  def binary_bitwise_operation(other, operator)
    raise ArgumentError.new("#{ other } is not a #{ BitArray }") unless other.is_a?(BitArray)
    BitArray.new(@size, @value.send(operator, other.value) & @ones)
  end
end