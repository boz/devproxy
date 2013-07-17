module Devproxy
  class Options < Struct.new(:user, :proxy, :port, :host, :remote_port)
    def username
      "devproxy-#{user}"
    end
    def valid?
      !( user.nil?  || user.empty?      ||
         proxy.nil? || proxy.empty?     ||
         port.nil?  || remote_port.nil? ||
         host.nil?  || host.empty?       )
    end
    def self.default
      default = new
      default.host        = "ssh.devproxy.io"
      default.remote_port = 2222
      default.port        = 3000
      default
    end
  end
end
