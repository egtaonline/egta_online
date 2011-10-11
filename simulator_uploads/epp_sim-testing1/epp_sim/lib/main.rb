require 'yaml'
require 'epp_sim'
#require 'jruby-prof'

#ARGV.each do|a|
#  puts "Argument: #{a}"
#end

#result = JRubyProf.profile do
#Logger.global.level = INFO
YAML_LOGGER = YAMLLogger.new(ARGV[0]+"/payoff_data", ARGV[0]+"/features")
time = Time.now().to_f
sim_parms = Array.new
File.open( ARGV[0]+"/simulation_spec.yaml" ) { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
#FileOutputter.new('payoff_data', Hash['filename', ARGV[0]+"/payoff_data"])
#FileOutputter.new('pricing_info', Hash['filename', ARGV[0]+"/pricing_info"])
ps = Simulator::ProfileSimulator.new(sim_parms[0], sim_parms[1])
count = 0
1.upto(ARGV[1].to_i) do
  count += 1
  ps.run()
end

puts count
puts Time.now().to_f-time
#end

#JRubyProf.print_flat_text(result, "flat.txt")