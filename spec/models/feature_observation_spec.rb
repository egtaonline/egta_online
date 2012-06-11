require 'spec_helper'

describe FeatureObservation do
  it { should be_embedded_in :profile }
  it { should validate_presence_of :observation_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :observation }
end