require 'webrick'
require 'cgi'
class Devproxy::CLI::Server < WEBrick::HTTPServer
  class Servlet < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request,response)
      token   = request.cookies.detect { |x| x.name == "DEVPROXY" }
      token &&= token.value
      token ||= "NONE"
      sysname = "#{%x{whoami}}@#{%x{hostname}}"

      response.status          = 200
      response['Content-Type'] = "text/html"
      response.body = %{
        <html>
        <head>
          <title>Devproxy Test Server</title>
        </head>
        <body>
          <h2>Hello from #{h(sysname)}</h2>
          <table>
            <tbody>
              <tr>
                <td>host</td><td>#{h(request.host)}</td>
              </tr>
              <tr>
                <td>token</td><td>#{h(token)}</td>
              </tr>
              <tr>
                <td>ssl?</td><td>#{request.ssl?}</td>
              </tr>
            </tbody>
          </table>
        </body>
        </html>
      }
    end
    def h(str)
      CGI::escape_html(str)
    end
  end
  def initialize(*args)
    super
    mount "/", Servlet
  end

  def start(*args)
    @mutex  ||= Mutex.new
    @thread ||= Thread.new do
      super(*args)
    end
  end

  def shutdown
    @mutex.synchronize do
      super
    end if @mutex
  end
end
