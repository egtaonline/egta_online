require 'spec_helper'

describe "schedulers/show.html.haml" do
  before(:each) do
    @scheduler = assign(:scheduler, stub_model(Scheduler))
  end

  it "renders attributes in <p>" do
    render
  end
end
