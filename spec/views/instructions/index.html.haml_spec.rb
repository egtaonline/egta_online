require 'spec_helper'

describe "instructions/index.html.haml" do
  before(:each) do
    assign(:instructions, [
      stub_model(Instruction),
      stub_model(Instruction)
    ])
  end

  it "renders a list of instructions" do
    render
  end
end
