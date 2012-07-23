object @object

attributes :id, :name, :simulator_fullname, :parameter_hash
child :roles do |r|
  attributes :name, :count, :strategies
end
if @adjusted == "true"
  if @full != "true"
    child :cv_manager do |cv|
      child :features => :features do |f|
        attributes :name, :expected_value, :adjustment_coefficient
      end
    end
    child :display_profiles => :profiles do |p|
      attributes :id
      node(:sample_count){|m| m.sample_count-10}
      child :role_instances => :roles do |r|
        attribute :name
        child :strategy_instances => :strategies do |s|
          attributes :name, :count
          node(:payoff){|m| @payoffs = m.adjusted_payoffs(@object.cv_manager); @payoffs.mean }
          node(:payoff_sd){|m| @payoffs.sd }
        end
      end
    end
  else
    child :display_profiles => :profiles do |p|
      attributes :id
      node(:sample_count){|m| m.sample_count-10}
      child :role_instances => :roles do |r|
        attribute :name
        child :strategy_instances => :strategies do |s|
          attributes :name, :count
          node(:payoff){|m| @payoffs = m.adjusted_payoffs(@object.cv_manager); @payoffs.mean }
          node(:payoff_sd){|m| @payoffs.sd }
        end
      end
      child :adjusted_sample_records => :sample_records do |s|
        node(:payoffs){|m| m.adjusted_payoffs(@object.cv_manager)}
        attribute :features
      end
    end
  end
else
  child :display_profiles => :profiles do |p|
    extends "api/v2/profiles/show"
  end
end