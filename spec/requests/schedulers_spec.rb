require 'spec_helper'

describe "Schedulers" do

  shared_examples "a scheduler" do
    context "POST /#{described_class.to_s.tableize}/update_parameters", :js => true do
      it "should update parameter info" do
        sim2 = Fabricate(:simulator, :parameter_hash => {"Parm2"=>"7","Parm3"=>"6"})
        visit "/#{described_class.to_s.tableize}/new"
        page.should have_content("Parm1")
        page.should have_content("Parm2")
        page.should_not have_content("Parm3")
        select sim2.fullname, :from => :simulator_id
        page.should_not have_content("Parm1")
        page.should have_content("Parm2")
        page.should have_content("Parm3")
      end
    end
    
    context "GET /#{described_class.to_s.tableize}" do
      it "should show all #{described_class.to_s.tableize}" do
        s1 = Fabricate(described_class.to_s.tableize.singularize.to_sym)
        s2 = Fabricate(described_class.to_s.tableize.singularize.to_sym)
        visit "/#{described_class.to_s.tableize}"
        page.should have_content("#{described_class.to_s.titleize}")
        page.should have_content(s1.name)
        page.should have_content(s2.name)
      end
    end
    
    context "GET /#{described_class.to_s.tableize}/new" do
      it "should show the new #{described_class.to_s.titleize} page" do
        Fabricate(:simulator)
        visit "/#{described_class.to_s.tableize}/new"
        page.should have_content("New #{described_class.to_s.titleize}")
        page.should have_content("Name")
      end
    end
    
    context "GET /#{described_class.to_s.tableize}/:id/edit" do
      it "should show the edit page for the #{described_class.to_s.titleize}" do
        visit "/#{described_class.to_s.tableize}/#{scheduler.id}/edit"
        page.should have_content("Edit #{described_class.to_s.titleize}")
        page.should have_content("Name")
      end
    end
    
    context "GET /#{described_class.to_s.tableize}/:id" do
      it "should show the relevant #{described_class.to_s.titleize}" do
        visit "/#{described_class.to_s.tableize}/#{scheduler.id}"
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should have_content(scheduler.name)
      end
    end
    
    context "PUT /#{described_class.to_s.tableize}/:id" do
      it "should update the relevant #{described_class.to_s.titleize}" do
        visit "/#{described_class.to_s.tableize}/#{scheduler.id}/edit"
        fill_in "Max samples", :with => "100"
        click_button "Update #{described_class.to_s.tableize.singularize.humanize}"
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should have_content("100")
      end
    end
    
    context "DELETE /#{described_class.to_s.tableize}/:id" do
      it "should delete the #{described_class.to_s.titleize}" do
        visit "/#{described_class.to_s.tableize}"
        click_on "Destroy"
        described_class.count.should eql(0)
      end
    end
  end

  describe Scheduler do
    it_behaves_like "a scheduler" do
      let!(:scheduler){Fabricate(:scheduler)}
    end
  end
  
  describe GameScheduler do
    it_behaves_like "a scheduler" do
      let!(:scheduler){Fabricate(:game_scheduler)}
    end
  end
  
  describe HierarchicalScheduler do
    it_behaves_like "a scheduler" do
      let!(:scheduler){Fabricate(:hierarchical_scheduler)}
    end
  end
end