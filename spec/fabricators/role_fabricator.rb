Fabricator(:role) do
  name {All}
  strategy_array { ['A', 'B']}
  after_create {|r| if r.strategy_array.is_a?(String); r.update_attribute(:strategy_array, eval(r.strategy_array)); end }
end