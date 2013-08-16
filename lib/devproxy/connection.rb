require 'devproxy/session'

module Devproxy
  class Connection < Struct.new(:options)
    MAX_DOTS  = 60

    def initialize options
      super
      reset_dots!
    end

    def loop!
      @session.shutdown! if @session
      @session = create_session
      @session.loop! if @session
    rescue Errno::ECONNREFUSED
      on_stderr "CONNECTION REFUSED.  Is there anything listening on port #{options.port}?"
      retry
    end

    def stop!
      @session.stop! if @session
    end

    def on_connected(proxy)
      $stdout.puts "Tunneling requests from https://#{proxy}.#{options.app_host} to #{options.listen} port #{options.port}"
    end

    def on_heartbeat data
      return unless options.verbose
      $stdout.write "."
      if (@dotno += 1) % MAX_DOTS == 0
        $stdout.write "\n"
      end
    end

    def on_stdout data
      $stdout.write("\n") if options.verbose
      $stdout.puts(data)
      reset_dots!
    end

    def on_stderr data
      $stdout.write("\n") if options.verbose
      $stderr.puts(data)
      reset_dots!
    end

    def on_close
      stop!
    end

    protected
    def create_session
      Session.create(options,self)
    rescue Errno::ECONNREFUSED
      on_stderr "CONNECTION REFUSED: can't connect to remote port #{options.remote_port}"
      stop!
    end

    def reset_dots!
      @dotno = 0
    end
    def self.loop!(options)
      create(options).loop!
    end
    def self.create(options)
      new(options)
    end
  end
end
