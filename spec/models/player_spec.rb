require 'spec_helper'

describe Player do
  it { should be_embedded_in(:symmetry_group) }
  it { should validate_presence_of(:payoff) }
  it { should validate_presence_of(:observation_id) }
  it { should have_field(:private_values).with_default_value_of({}) }
end