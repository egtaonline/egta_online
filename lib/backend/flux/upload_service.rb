class UploadService
  def initialize(upload_connection)
    @upload_connection = upload_connection
  end
  
  def upload_simulation!(simulation, src_dir="#{Rails.root}/tmp/simulations")
    begin
      @upload_connection.upload!("#{src_dir}/#{simulation.number}", "#{Yetting.deploy_path}/simulations", recursive: true) do |ch, name, sent, total|
        puts "#{name}: #{sent}/#{total}"
      end
      "#{Yetting.deploy_path}/simulations/#{simulation.number}"
    rescue Exception => e
      simulation.fail 'could not complete the transfer to remote host.  Speak to Ben to resolve.'
      nil
    end
  end
  
  def upload_simulator!(simulator)
    @upload_connection.upload!(simulator.simulator_source.path, "#{Yetting.deploy_path}/#{simulator.name}.zip")
  end
end