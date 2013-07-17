require 'net/ssh'
require 'devproxy/net-ssh-patch'

module Devproxy
  class Connection
    attr_reader :options, :ssh

    MAX_DOTS = 60

    def initialize options, ssh
      @options , @ssh   = options , ssh
      @halt    , @dotno = false   , 0
    end

    def loop!
      @ssh.loop { !halt? }
    end
    def stop!
      @halt = true
    end
    def halt?
      @halt
    end

    def on_stdout data
      if (@dotno += 1) % MAX_DOTS == 0
        $stdout.puts "\n"
      end
      $stdout.write data
    end

    def on_stderr data
      @dotno = 0
      $stderr.puts "\nError: #{data}"
    end

    def self.loop!(options)
      create(options).loop!
    end

    def self.create(options)
      ssh        = open_ssh(options)
      connection = new(options,ssh)
      ssh.forward.remote(options.port,"localhost",0,'0.0.0.0')
      ssh.exec(options.proxy) do |channel,stream,data|
        if stream == :stdout
          connection.on_stdout data
        else
          connection.on_stderr data
        end
      end
      connection
    end
    def self.open_ssh(options)
      Net::SSH.start(options.host, options.username,{
        :port => options.remote_port,
      })
    end
  end
end
