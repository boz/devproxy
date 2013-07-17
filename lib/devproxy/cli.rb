require 'devproxy/connection'
require 'devproxy/options'
require 'optparse'
module Devproxy
  class CLI < Struct.new(:options,:connection)
    def loop!
      connection.loop!
    end
    def stop!
      connection.stop!
    end
    def self.parse(argv)
      options = Devproxy::Options::default
      opts    = OptionParser.new
      opts.banner = "Usage: devproxy user [proxy] [options...]"

      opts.separator ""
      opts.separator "    user: \tDevproxy username."
      opts.separator "    proxy:\tThe name of the proxy you want to connect to (without the domain)."
      opts.separator "          \tDefaults to `user`."
      opts.separator "          \texample: 'foo' for tunneling 'foo.devproxy.io'"

      opts.separator ""

      opts.on "-p PORT", "--port PORT", Integer,
              "Local port accepting connections (default: #{options.port})" do |x|
        options.port = x
      end

      if ENV['DEVPROXY_DEVELOPMENT']
        opts.on "--host HOST", "remote hostname." do |x|
          options.host = x
        end
        opts.on "--remote-port PORT",Integer,"remote SSH port" do |x|
          options.remote_port = x
        end
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
      options.proxy = argv[1] || argv[0]
      unless options.valid?
        puts opts
        exit
      end
      options
    end
    def self.create(argv)
      options = parse(argv)
      new(options,Devproxy::Connection.create(options))
    end
  end
end
