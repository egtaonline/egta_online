require 'spec_helper'

describe "schedulers/edit.html.haml" do
  before(:each) do
    @scheduler = assign(:scheduler, stub_model(Scheduler))
  end

  it "renders the edit scheduler form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => schedulers_path(@scheduler), :method => "post" do
    end
  end
end
