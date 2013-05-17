require 'spec_helper'

# Needs to be renamed
describe ProfileScheduler do
  describe '#perform' do
    let(:profile_id){ Moped::BSON::ObjectId.from_time(Time.now) }

    context 'flawless victory' do
      let(:profile){ double(id: profile_id, sample_count: 20, scheduled?: false, schedulers: schedulers) }
      let(:criteria){ double("Criteria") }
      let(:scheduler1) { double('scheduler1') }
      let(:scheduler2) { double('scheduler2') }
      let(:schedulers) { double(with_max_samples: scheduler1) }
      before do
        Profile.should_receive(:where).with(_id: profile_id).and_return(criteria)
        criteria.should_receive(:without).with(:symmetry_groups, :observations).and_return([profile])
        scheduler1.should_receive(:schedule_profile).with(profile)
      end

      it { subject.perform(profile_id) }
    end
  end
end