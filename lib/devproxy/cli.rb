require 'devproxy/connection'
require 'devproxy/options'
require 'optparse'

module Devproxy
  class CLI < Devproxy::Connection
    class Options < Devproxy::Options
      attr_accessor(:test)
    end

    autoload :Server, 'devproxy/cli/server'

    def initialize *args
      super(*args)
      initialize_test_server
    end

    def loop!
      start_test_server
      super
    end

    def stop!
      stop_test_server
      super
    end

    protected
    def testing?
      options.test
    end

    def initialize_test_server
      return unless testing?
      @test_server = Server.new({
        :Port        => options.port,
        :BindAddress => options.listen,
      })
    end

    def start_test_server
      return unless testing?
      @test_server.start
    end
    def stop_test_server
      return unless testing?
      @test_server.stop
    end

    def self.parse(argv)
      options = Options::default
      opts    = OptionParser.new
      opts.banner = "Usage: devproxy user [proxy] [options...]"

      opts.separator ""
      opts.separator "    user: \tDevproxy username."
      opts.separator "    proxy:\tThe name of the proxy you want to connect to (without the domain)."
      opts.separator "          \tDefaults to the user's default proxy."
      opts.separator "          \texample: 'foo' for tunneling 'foo.devproxy.io'"

      opts.separator ""

      opts.on "-p PORT", "--port PORT", Integer,
              "Local port accepting connections (default: #{options.port})" do |x|
        options.port = x
      end

      opts.on "--test-server", "Launch local server for testing" do |x|
        options.test = true
      end

      opts.on "-v", "--verbose",
              "Verbose output (default: #{options.verbose})" do |x|
        options.verbose = true
      end

      if ENV['DEVPROXY_DEVELOPMENT']
        opts.on "-l ADDRESS", "--listen ADDRESS",
                "Local address to listen on (default: #{options.listen})" do |x|
          options.listen = x
        end
        opts.on "--host HOST", "remote hostname." do |x|
          options.host = x
        end
      end

      opts.on "--remote-port PORT",Integer,"remote SSH port (default: #{options.remote_port})" do |x|
        options.remote_port = x
      end

      opts.on_tail "-h", "--help", "show this message" do
        puts opts
        exit
      end

      opts.on_tail "--version", "Show version" do
        puts Devproxy::VERSION.join('.')
        exit
      end
      opts.parse!(argv)
      options.user  = argv[0]
      options.proxy = argv[1]
      unless options.valid?
        puts opts
        exit
      end
      options
    end
    def self.create(argv)
      super(parse(argv))
    end
  end
end
