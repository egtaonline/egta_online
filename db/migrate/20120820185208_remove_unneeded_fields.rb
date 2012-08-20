class RemoveUnneededFields < Mongoid::Migration
  def self.up
    Profile.where(:feature_avgs.exists => true).unset(:feature_avgs)
    Profile.where(:feature_expected_values.exists => true).unset(:feature_expected_values)
    Profile.where(:feature_stds.exists => true).unset(:feature_stds)
    Profile.where(:role_instances.exists => true).unset(:role_instances)
    Profile.where(:sampled.exists => true).unset(:sampled)
    Profile.where(:proto_string.exists => true).unset(:proto_string)
  end

  def self.down
  end
end