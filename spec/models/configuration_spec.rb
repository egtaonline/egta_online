require 'spec_helper'

describe Configuration do
  it { should belong_to :configurable }
  it { should have_many :profiles }
end