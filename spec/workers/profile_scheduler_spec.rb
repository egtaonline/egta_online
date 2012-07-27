require 'spec_helper'

# Needs to be renamed
describe ProfileScheduler do
  describe 'perform' do
    let(:profile_id){ BSON::ObjectId.from_time(Time.now) }
    
    context 'flawless victory' do
      let(:profile){ double(id: profile_id, sample_count: 20, scheduled?: false) }
      let(:scheduler1) { double('scheduler1') }
      let(:scheduler2) { double('scheduler2') }
      
      before do
        Profile.should_receive(:find).with(profile_id).and_return(profile)
        schedulers = [scheduler1, scheduler2]
        scheduler2.should_receive(:required_samples).with(profile_id).and_return(5)
        scheduler1.should_receive(:required_samples).with(profile_id).and_return(10)
        Scheduler.should_receive(:scheduling_profile).with(profile_id).and_return(schedulers)
        scheduler1.should_receive(:schedule_profile).with(profile)
      end
      
      it { ProfileScheduler.perform(profile_id) }
    end
  end
end