#!/usr/bin/env ruby
require 'daemons'
# You might want to change this
ENV["RAILS_ENV"] ||= "production"

pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/../../config/jobs.rb'

Daemons.run_proc(
  'stalker_daemon', # name of daemon
  :dir_mode => :normal,
  :dir => File.join(pwd, '../../tmp/pids'),
  :backtrace => true,
  :monitor => true,
  :log_output => true
) do
  exec "stalk #{file}"
end