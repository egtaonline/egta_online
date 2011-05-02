require 'spec_helper'

describe "instructions/new.html.haml" do
  before(:each) do
    assign(:instruction, stub_model(Instruction).as_new_record)
  end

  it "renders new instruction form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => instructions_path, :method => "post" do
    end
  end
end
