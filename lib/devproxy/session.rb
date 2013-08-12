require 'net/ssh'
require 'devproxy/net-ssh-patch'

module Devproxy
  class Session < Struct.new(:ssh)
    class Error                 < StandardError; end
    class Error::Authentication < Error        ; end

    HEARTBEAT = "HEARTBEAT"
    CONNECT   = "CONNECT:"

    def shutdown!
      ssh.shutdown!
    end

    def loop!
      ssh.loop { !@halt }
    end

    def stop!
      @halt = true
    end

    def self.create(options,connection)
      ssh        = open_ssh(options)
      ssh.forward.remote(options.port,options.listen,0,'0.0.0.0')
      channel    = ssh.exec(options.proxy) do |ch,stream,data|
        if stream == :stdout
          if data.start_with?(HEARTBEAT)
            connection.on_heartbeat(data)
          elsif data.start_with?(CONNECT)
            connection.on_connected(data[(CONNECT.size)..-1].chomp)
          else
            connection.on_stdout(data)
          end
        else
          connection.on_stderr(data)
        end
      end
      channel.on_close do
        connection.on_close
      end
      new(ssh)
    rescue Net::SSH::AuthenticationFailed
      raise Error::Authentication, "Authentication Failed: Invalid username or SSH key"
    end
    def self.open_ssh(options)
      Net::SSH.start(options.host, options.username,{
        :port => options.remote_port,
        :user_known_hosts_file => "/dev/null",
      })
    end
  end
end
