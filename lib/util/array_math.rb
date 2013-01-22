class ArrayMath
  def self.average(array)
    array.reduce(:+).to_f/array.length
  end
  
  def self.std_dev(array)
    Math.sqrt([array.map{ |elem| elem**2.0 }.reduce(:+).to_f/array.length-average(array)**2.0, 0].max)
  end
end