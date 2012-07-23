class TransferService
  def initialize(transfer_connection)
    @transfer_connection = transfer_connection
  end
  
  def upload_simulation!(simulation, src_dir="#{Rails.root}/tmp/simulations")
    begin
      @transfer_connection.upload!("#{src_dir}/#{simulation.number}", "#{Yetting.deploy_path}/simulations", recursive: true) do |ch, name, sent, total|
        puts "#{name}: #{sent}/#{total}"
      end
      true
    rescue Exception => e
      simulation.fail 'could not complete the transfer to remote host.  Speak to Ben to resolve.'
      false
    end
  end
  
  def upload_simulator!(simulator)
    @transfer_connection.upload!(simulator.simulator_source.path, "#{Yetting.deploy_path}/#{simulator.name}.zip")
  end
end