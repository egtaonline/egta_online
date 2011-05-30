Fabricator(:run_time_configuration) do
  parameters { Hash[:a => 2] }
  after_create {|rtc| if rtc.parameters.is_a?(String); rtc.update_attributes(:parameters => eval(rtc.parameters)); end }
end