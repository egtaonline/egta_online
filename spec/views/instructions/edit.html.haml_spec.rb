require 'spec_helper'

describe "instructions/edit.html.haml" do
  before(:each) do
    @instruction = assign(:instruction, stub_model(Instruction))
  end

  it "renders the edit instruction form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => instructions_path(@instruction), :method => "post" do
    end
  end
end
