require 'spec_helper'

describe SchedulerObserver do
  shared_examples "resets profiles" do
    it { Profile.with_scheduler(scheduler).count.should == 0 }
  end

  shared_examples "gathers new profiles" do
    it { ProfileAssociater.should have_queued(scheduler.id) }
  end

  [GameScheduler, HierarchicalScheduler, DeviationScheduler, HierarchicalDeviationScheduler, GenericScheduler].each do |scheduler_class|
    describe scheduler_class do
      let(:scheduler){ Fabricate("#{scheduler_class.to_s.underscore}_with_profiles".to_sym) }

      before(:each) do
        ResqueSpec.reset!
      end

      context "when size has changed" do
        before(:each) do
          scheduler.update_attribute(:size, 6)
        end

        it_behaves_like "resets profiles"

        if scheduler_class != GenericScheduler
          it_behaves_like "gathers new profiles"
        end
      end

      context "when configuration has changed" do
        before(:each) do
          scheduler.update_attribute(:configuration, { "Updated" => true })
        end

        it_behaves_like "resets profiles"

        if scheduler_class != GenericScheduler
          it_behaves_like "gathers new profiles"
        end
      end

      describe 'schedules profiles' do
        let(:scheduler){ Fabricate("#{scheduler_class.to_s.underscore}".to_sym) }
        let(:profile_array){ [double('profile1'), double('profile2')] }

        before do
          profile_array.each{ |p| p.should_receive(:try_scheduling) }
          Profile.should_receive(:with_scheduler).with(scheduler).and_return(profile_array)
          Resque.stub(:enqueue)
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
end