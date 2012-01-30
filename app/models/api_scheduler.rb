class ApiScheduler < Scheduler
  def self.convert_to_proto_string(name_string)
    if name_string =~ /^(\S+: (\S+, )*\S+; )*\S+: (\S+, )*\S+$/
      r = name_string.split("; ").sort.collect do |role|
        role.split(": ")[0]+": "+role.split(": ")[1].split(", ").sort.collect{|s| ::Strategy.where(:name => s).first.number}.join(", ")
      end
      r.join("; ")
    else
      ""
    end
  end
  
  #TODO add note that ',' and ';' are not valid for strategy names
  def self.size_of_profile(name_string)
    name_string.count(",")+name_string.count(";")+1
  end
end