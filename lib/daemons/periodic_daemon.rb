#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
require 'helper_demon'

Rails.application.require_environment!
process_schedulers_time = Time.now
queue_simulations_time = Time.now
maintain_simulations_time = Time.now

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  if(Time.now-process_schedulers_time > 100)
    HelperDemon.process_schedulers
    process_schedulers_time = Time.now
  end
  if(Time.now-queue_simulations_time > 200)
    HelperDemon.queue_simulations
    queue_simulations_time = Time.now
  end
  if(Time.now-maintain_simulations_time > 300)
    HelperDemon.maintain_simulations
    maintain_simulations_time = Time.now
  end
  sleep 10
end