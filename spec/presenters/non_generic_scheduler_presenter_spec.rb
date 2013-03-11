require 'spec_helper'

describe NonGenericSchedulerPresenter do
  describe '#to_json' do
    it 'presents the appropriate representation as a string' do
      scheduler = stub(id: 'fake_id', name: 'fake_name', simulator_id: 'fake_sim_id', configuration: {}, active: true, process_memory: 1000,
                       time_per_sample: 15, size: 6, roles: [stub(name: 'All', count: 6, strategies: ['A'])], samples_per_simulation: 1, nodes: 1, default_samples: 5)
      criteria = double('Criteria')
      Profile.should_receive(:where).with(scheduler_ids: 'fake_id').and_return(criteria)
      criteria.should_receive(:only).with(:sample_count).and_return([{"_id" => 1, "sample_count" => 10}])
      NonGenericSchedulerPresenter.new(scheduler).to_json.should == '{"_id":"fake_id","name":"fake_name","simulator_id":"fake_sim_id",' <<
                                                                    '"configuration":{},"active":true,"process_memory":1000,"time_per_sample":15,"size":6,' <<
                                                                    '"default_samples":5,"roles":[{"name":"All","count":6,"strategies":["A"]}],"samples_per_simulation":1,"nodes":1,' <<
                                                                    '"sample_set":[{"_id":1,"sample_count":10}]}' << "\n"
    end
  end
end