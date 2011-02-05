#TODO: can be made much more terse using expected names and method_missing

module PBS
  class Config

    def node_file
      @node_file ||= ENV['PBS_NODEFILE']
    end
    
    def nodes
      @nodes ||= parse_nodes
    end
    
    def job_id
      @job_id ||= ENV['PBS_JOBID']
    end
    
    def simulation_id
      @simulation_id ||= ENV['SIM_ID']
    end
    
    def server
      @server ||= ENV['SERVER']
    end
    
    def simulation_location
      @simulation_location ||= ENV['SIMLATION_LOCATION']
    end
    
    def samples
      @samples ||= (ENV['SAMPLES'] || 0).to_i
    end
    
    private 
    
    def parse_nodes
      text = ""
      
      begin
        f = File.new node_file
        text = f.read
      rescue => e
        puts e
      end
      
      text.split("\n")
    end
  end
end