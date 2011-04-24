module PBS
  module Submission
    QSUB_CMD = "qsub"

    attr_accessor :script

    def command
      cmd = ["#{QSUB_CMD}"]

      # Export environment variables
      cmd << "-V"

      # Set job as non-rerunable
      cmd << "-r n"

      # Add the resource list
      cmd << "-l #{resource_list}"

      # Add the arguments
      cmd << "-v #{arguments_as_list}"

      # Add the script
      cmd << "#{script}"

      cmd.join(' ')
    end
  end

  class MASSubmission
    include Submission

    DEFAULT_NODES = 1

    attr_accessor :process_memory, :qos, :time_per_sample, :script, :samples, :players, :simulation_id, :nodes

    def initialize(pbs_proxy, samples, simulation_id, script)
      @process_memory = pbs_proxy.process_memory
      @qos = "cac"
      @samples = samples
      @time_per_sample = pbs_proxy.time_per_sample
      @script = script
      @simulation_id = simulation_id
    end

    def pbs_wall_time
      [wall_time_hours, wall_time_minutes, wall_time_seconds].collect do |t|
        "%02d" % t
      end.join(':')
    end

    def wall_time_hours
      wall_time/3600
    end

    def wall_time_minutes
      (wall_time - (wall_time_hours*3600))/60
    end

    def wall_time_seconds
      (wall_time-(wall_time_hours*3600)-(wall_time_minutes*60))
    end

    def wall_time
      @time_per_sample*samples
    end

    def nodes
      @nodes || DEFAULT_NODES
    end

    def resource_list
      resources = []

      # Set the number of nodes
      resources << "nodes=#{nodes}"

      # Set the process memory
      resources << "pmem=#{process_memory}mb"

      # Set the Wall time
      resources << "walltime=#{pbs_wall_time}"

      # Set the quality of service
      resources << "qos=#{qos}"

      resources.join(',')
    end

    def arguments_as_list
      arguments = []

      {:SAMPLES=>@samples,
       :SIMULATION_LOCATION=>"simulations/#{simulation_id}"}.each_pair do |key,value|
        arguments << "#{key}=#{value}"
      end

      arguments.join(',')
    end
  end
end
