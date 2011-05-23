# This model class represents games and corresponding Profiles are automatically
# generated given possible strategy_array

class SymmetricGame < Game

  def ensure_profiles

    p = Array.new(self.size, 0)
    while p != nil
      p_strategy_array = p.collect {|i| strategy_array[i]}
      p_strategy_array.sort!
      profile = profiles.detect {|x| x.strategy_array == p_strategy_array}
      unless profile
        prof = SymmetricProfile.new
        p_strategy_array.each do |strategy|
          if prof[strategy] == nil
            prof[strategy] = 1
            prof.profile_entries.create!(:name => strategy)
          else
            prof[strategy] += 1
          end
        end
        self.profiles << prof
        prof.save!
      end

      p = next_profile(p, strategy_array.length, self.size)
    end
  end

  def next_profile(array, n_strategy_array, profile_size)
    if array.nil? || array.empty?
      nil
    elsif array.last == (n_strategy_array - 1)
      next_profile(array[0..-2], n_strategy_array, profile_size)
    else
      a = array.clone
      a[-1] += 1
      a.concat(Array.new(profile_size - a.length, a[-1]))
      a
    end
  end

end