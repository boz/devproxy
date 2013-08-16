module Devproxy
  class Options < Struct.new(:user, :proxy, :port, :host, :remote_port, :listen, :verbose)
    def username
      "devproxy-#{user}" if !!user && !user.empty?
    end
    def valid?
      !( user.nil?  || user.empty?      ||
         port.nil?  || remote_port.nil? ||
         host.nil?  || host.empty?       )
    end
    def app_host
      host.split(".")[-2..-1].join(".")
    end
    def self.default
      default = new
      default.host        = "ssh.devproxy.io"
      default.remote_port = 2222
      default.port        = 3000
      default.listen      = "0.0.0.0"
      default.verbose     = false
      default
    end
  end
end
