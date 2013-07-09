require "devproxy/version"
require "net/ssh"

class Net::SSH::Service::Forward
    def remote(port, host, remote_port, remote_host="127.0.0.1",&blk)
      session.send_global_request("tcpip-forward", :string, remote_host, :long, remote_port) do |success, response|
        if success
          remote_port = response.read_long if remote_port.zero?
          debug { "remote forward from remote #{remote_host}:#{remote_port} to #{host}:#{port} established" }
          blk.call(remote_port) if blk
          @remote_forwarded_ports[[remote_port, remote_host]] = Remote.new(host, port)
        else
          error { "remote forwarding request failed" }
          raise Net::SSH::Exception, "remote forwarding request failed"
        end
      end
    end
end


module Devproxy
  # Your code goes here...
  def self.connect username, proxyname, port
    Net::SSH.start("devproxy.net", "devproxy-#{username}", {:port => 2222}) do |ssh|
      ssh.forward.remote(port, "localhost", 0, '0.0.0.0')
      channel = ssh.open_channel do |ch|
        ch.exec(proxyname) do |ch,success|
          ch.on_data do |ch,data|
            $stdout.write(data)
          end
          ch.on_close do
            puts "done"
          end
        end
      end
      channel.wait
      ssh.loop { true }
    end
  end
end
