require 'util/array_math'

describe ArrayMath do
  it "can calculate the average of an array" do
    ArrayMath.average([11, 10, 14]).should == 35.0/3.0
  end
  
  it "can calculate the std deviation of a sufficiently large array" do
    ArrayMath.std_dev([11, 10, 14]).should == Math.sqrt((121.0+100.0+196.0)/3.0-(35.0/3.0)**2.0)
  end
  
  it "returns 0 if there are insufficient samples when calculating the std deviation" do
    ArrayMath.std_dev([1]).should == 0
  end
end