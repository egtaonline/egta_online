class ArrayMath
  def self.average(array)
    array.reduce(:+).to_f/array.length
  end
  
  def self.std_dev(array)
    return 0 unless array.length > 1
    Math.sqrt(array.map{ |elem| elem**2.0 }.reduce(:+).to_f/array.length-average(array)**2.0)
  end
end