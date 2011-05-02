require 'spec_helper'

describe "instructions/show.html.haml" do
  before(:each) do
    @instruction = assign(:instruction, stub_model(Instruction))
  end

  it "renders attributes in <p>" do
    render
  end
end
