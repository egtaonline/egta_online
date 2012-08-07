require 'net/ssh'
require 'net/scp'
require 'socket'
require 'thread'
require 'oj'

class SSHProxy
  def initialize(port)
    until ARGV.empty? do
      ARGV.shift
    end

    puts 'Uniqname: '
    uniqname = gets.split("\n")[0]
    @transfer = Net::SCP.start('flux-xfer.engin.umich.edu', uniqname)
    @login = Net::SSH.start('flux-login.engin.umich.edu', uniqname)

    @request_queue = SizedQueue.new(100)
    @server_sock = TCPServer.new port
  end

  def start
    @accept_thread = Thread.new do
      handle_requests
    end
 
    @processing_thread = Thread.new do
      process_requests
    end

    puts 'daemonizing'

    #puts Process.daemon(true, true)

    @processing_thread.join
    puts "shouldn't get here"
  end
  
  def handle_requests
    loop do
      client = @server_sock.accept
      request = client.gets
      @request_queue.push([request, client])
    end
  end
 
  def run_command!(cmd)
    response = ''
    err = ''
    status = ''
    @login.open_channel() do |channel|
      channel.on_data do |ch, data|
        response += data
      end
 
      channel.on_extended_data do |ch, type, data|
        err += data
      end
 
      channel.on_request('exit-status') do |ch, data|
        status += data.read_long
      end
      channel.exec!(cmd) { |ch, success| }
    end
    response
  end

  def download!(request_hash)
    @transfer.download!(request_hash['src'], request_hash['destination'], recursive: true)
  end

  def upload!(request_hash)
    @transfer.upload!(request_hash['src'], request_hash['destination'], recursive: true)
  end

  def process_requests
    loop do
      request, client = @request_queue.pop
      request_hash = Oj.load(request)
      result = (request_hash['type'] == 'ssh' ? run_command!(request_hash['cmd']) : (request_hash['cmd'] == 'upload' ? upload!(request_hash) : download!(request_hash) ) )
      client.puts result
 
      client.close # this handles one request per client -- could keep the
                     # socket open if muptiple requests are possible
    end
  end
end

ssh_proxy = SSHProxy.new(30000)
ssh_proxy.start