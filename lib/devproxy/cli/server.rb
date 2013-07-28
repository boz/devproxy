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
          <link rel="stylesheet" href="/css/style.css">
          <title>Devproxy Test Server</title>
        </head>
        <body>
          <h1>Hello from #{h(sysname)}</h2>
          <div class="details">
            <table>
              <caption>Tunnel Details</caption>
              <tbody>
                <tr>
                  <td>host</td><td>#{h(request.host)}</td>
                </tr>
                <tr>
                  <td>protocol</td><td>#{h(request['x-forwarded-proto'])}</td>
                </tr>
                <tr>
                  <td>token</td><td>#{h(token)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </body>
        </html>
      }
    end
    def do_POST(request,response)
      do_GET(request,response)
    end
    def h(str)
      CGI::escape_html(str)
    end
  end
  def initialize(*args)
    super
    mount "/"   , Servlet
    mount "/css", WEBrick::HTTPServlet::FileHandler, File.join(File.dirname(__FILE__),"..","..","..","data","css")
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
