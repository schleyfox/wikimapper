require 'rubygems'
require 'mongrel'
require 'logger'

def stripdot(txt)
  CGI::unescape(txt).gsub(/[^A-Za-z0-9_]/, '_')
end

$file = File.open("wiki_map.dot", "w")

class HeaderHandler < Mongrel::HttpHandler


  def process(request,response)
    response.start(200) do |head, out|
      head["Content-Type"] = "text/plain"
      vars = Mongrel::HttpRequest.query_parse(request.params['QUERY_STRING'])
      if vars['exit'] == '1'
        $file.puts '}'
        $file.close
        exit! 
      elsif vars['single']
        $file.puts "  #{stripdot vars['single']};"
      else
        $file.puts "  #{stripdot vars['from']} -> #{stripdot vars['to']};"
      end
    end
  end
end


$file.puts "digraph wiki_map {"
server = Mongrel::HttpServer.new("127.0.0.1", "9999")
server.register("/", HeaderHandler.new)
server.register("/favicon.ico", Mongrel::Error404Handler.new(""))
server.run.join


