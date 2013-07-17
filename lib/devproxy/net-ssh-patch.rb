require "net/ssh"

#
# Read remote port from channel.
#
# https://github.com/net-ssh/net-ssh/pull/99
#

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
