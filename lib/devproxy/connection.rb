require 'net/ssh'
require 'devproxy/net-ssh-patch'

module Devproxy
  class Connection
    class Error                 < StandardError; end
    class Error::Authentication < Error        ; end

    attr_reader :options, :ssh

    MAX_DOTS = 60

    def initialize options, ssh
      @options, @ssh, @halt = options, ssh, false
      reset_dots!
    end

    def loop!
      @ssh.loop { !halt? }
    rescue Errno::ECONNREFUSED
      on_stderr "CONNECTION REFUSED.  Is there anything listening on port #{options.port}?"
      retry
    end
    def stop!
      @halt = true
    end
    def halt?
      @halt
    end

    def on_stdout data
      $stdout.write data
      if (@dotno += 1) % MAX_DOTS == 0
        $stdout.write "\n"
      end
    end

    def on_stderr data
      $stderr.puts "\nError: #{data}"
      reset_dots!
    end

    def on_close
      stop!
    end

    protected
    def reset_dots!
      @dotno = 0
    end

    def self.loop!(options)
      create(options).loop!
    end

    def self.create(options)
      ssh        = open_ssh(options)
      connection = new(options,ssh)
      ssh.forward.remote(options.port,"localhost",0,'0.0.0.0')
      channel    = ssh.exec(options.proxy) do |ch,stream,data|
        if stream == :stdout
          connection.on_stdout(data)
        else
          connection.on_stderr(data)
        end
      end
      channel.on_close do
        connection.on_close
      end
      connection
    rescue Net::SSH::AuthenticationFailed
      raise Error::Authentication, "Authentication Failed: Invalid username or SSH key"
    end
    def self.open_ssh(options)
      Net::SSH.start(options.host, options.username,{
        :port => options.remote_port,
      })
    end
  end
end
