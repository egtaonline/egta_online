require 'spec_helper'

describe SchedulerObserver do
  shared_examples "resets profiles" do
    it { scheduler.profile_ids.should == [] }
  end
  
  shared_examples "gathers new profiles" do
    it { ProfileAssociater.should have_queued(scheduler.id) }
  end
  
  shared_examples "schedules profiles" do
    it { scheduler.profiles.each{ |p| ProfileScheduler.should have_queued(p.id) } }
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
      
      it_behaves_like "schedules profiles" do
        context "when scheduler becomes active" do
          let(:scheduler){ Fabricate("#{scheduler.to_s.underscore}_with_profiles".to_sym, active: false) }
          before(:each) do
            scheduler.update_attribute(:active, true)
          end
        end
        
        if scheduler_class != GenericScheduler
          context "when max sample changes" do
            before(:each) do
              scheduler.update_attribute(:default_samples, 50)
            end
          end
        end
      end
    end
  end
end