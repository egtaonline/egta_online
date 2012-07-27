class Object
  def numeric?
    true if Float(self) rescue false
  end
end