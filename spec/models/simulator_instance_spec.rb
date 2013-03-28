require 'spec_helper'

describe SimulatorInstance do
  describe '#get_storage_key' do
    let(:simulator_instance){ Fabricate(:simulator_instance) }

    it 'returns unique keys' do
      simulator_instance.get_storage_key('featurea').should_not == simulator_instance.get_storage_key('featureb')
    end

    it 'returns the same key for existing entries' do
      simulator_instance.get_storage_key('featurea').should == simulator_instance.get_storage_key('featurea')
    end
  end
end