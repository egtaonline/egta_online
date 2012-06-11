class Hash
  def fully_sort
    sorted_hash = {}
    self.sort.each{ |key, value| sorted_hash[key] = value.is_a?(Hash) ? value.fully_sort : value }
    sorted_hash
  end
end