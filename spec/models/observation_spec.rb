require 'spec_helper'

describe Observation do
  it "tracks timestamps" do
    profile = Fabricate(:profile)
    profile.observations.create!
    time = Time.now
    profile.observations.create!
    profile.observations.count.should == 2
    profile.observations.where(:u_at.lt => time).count.should == 1
  end
end