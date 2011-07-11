class AsymmetricProfile < Profile
  def create_profile_entries
    proto = proto_string.split(", ")
    proto.each_index {|index| profile_entries.create(:name => "Player#{index}: #{proto[index]}")}
  end
end