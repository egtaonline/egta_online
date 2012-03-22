# Load the rails application
require 'yaml' 
YAML::ENGINE.yamler= 'syck'
require File.expand_path('../application', __FILE__)

# Initialize the rails application
EgtaOnline::Application.initialize!
