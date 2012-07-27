class DownloadService
  def initialize(download_connection, destination="#{Rails.root}/tmp/data")
    @download_connection, @destination = download_connection, destination
  end
  
  def download_simulation!(simulation)
    begin
      @download_connection.download!("#{Yetting.deploy_path}/simulations/#{simulation.number}", @destination, recursive: true) do |ch, name, sent, total|
        puts "#{name}: #{sent}/#{total}"
      end
      "#{@destination}/#{simulation.number}"
    rescue Exception => e
      simulation.fail 'could not complete the transfer from remote host.  Speak to Ben to resolve.'
      nil
    end
  end
end