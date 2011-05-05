require 'spec_helper'

describe "schedulers/new.html.haml" do
  before(:each) do
    assign(:scheduler, stub_model(Scheduler).as_new_record)
  end

  it "renders new scheduler form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => schedulers_path, :method => "post" do
    end
  end
end
