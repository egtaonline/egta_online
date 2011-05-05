require 'spec_helper'

describe "schedulers/index.html.haml" do
  before(:each) do
    assign(:schedulers, [
      stub_model(Scheduler),
      stub_model(Scheduler)
    ])
  end

  it "renders a list of schedulers" do
    render
  end
end
