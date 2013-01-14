require 'spec_helper'

describe SchedulerObserver do
  [GameScheduler, HierarchicalScheduler, DeviationScheduler, HierarchicalDeviationScheduler, GenericScheduler].each do |scheduler_class|
    describe scheduler_class do
      let!(:scheduler){ Fabricate("#{scheduler_class.to_s.underscore}_with_profiles".to_sym) }

      context "when size has changed" do
        it "gathers the new profiles" do
          if scheduler_class != GenericScheduler
            ProfileAssociater.should_receive(:perform_async).with(scheduler.id)
          end
          scheduler.update_attribute(:size, 6)
          Profile.with_scheduler(scheduler).count.should == 0
        end
      end

      context "when configuration has changed" do
        it "gathers the new profiles" do
          if scheduler_class != GenericScheduler
            ProfileAssociater.should_receive(:perform_async).with(scheduler.id)
          end
          scheduler.update_attribute(:configuration, { "Updated" => true })
          Profile.with_scheduler(scheduler).count.should == 0
        end
      end
    end

    describe 'schedules profiles' do
      let(:scheduler){ Fabricate("#{scheduler_class.to_s.underscore}".to_sym) }
      let(:profile_array){ [double('profile1'), double('profile2')] }

      before do
        profile_array.each{ |p| p.should_receive(:try_scheduling) }
        Profile.should_receive(:with_scheduler).with(scheduler).and_return(profile_array)
      end

      it "when the scheduler becomes active" do
        scheduler.update_attribute(:active, true)
      end

      it "when max sample changes" do
        scheduler.update_attribute(:default_samples, 50)
      end
    end
  end
end