require 'rubygems'
require 'mongrel'
require 'logger'
require 'active_record'

$db_name = 'wiki_dot.db'
$dot_fn = 'wiki_map.tmp.dot'
$png_fn = 'wiki_map.tmp.png'

if !File.exists? $db_name
  require 'sqlite3'
  db = SQLite3::Database.new($db_name)
  db.execute %q{ 
    CREATE TABLE lines(
      id INTEGER PRIMARY KEY,
      created_at DATETIME,
      line TEXT);
    }
  db.close
end



ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3', 
  :dbfile => $db_name})

class Line < ActiveRecord::Base
end


def stripdot(txt)
  CGI::unescape(txt).gsub(/[^A-Za-z0-9_]/, '_')
end


class WikiLoggerHandler < Mongrel::HttpHandler
  def process(request,response)
    response.start(200) do |head, out|
      head["Content-Type"] = "text/plain"
      vars = Mongrel::HttpRequest.query_parse(request.params['QUERY_STRING'])

      if vars['single']
        Line.new(:line => "#{stripdot vars['single']};").save
      else
        Line.new(
          :line => "#{stripdot vars['from']} -> #{stripdot vars['to']};").save
      end
    end
  end
end

class WikiMapDisplayHandler < Mongrel::HttpHandler
  def process(request,response)
    response.start(200) do |head, out|
      head["Content-Type"] = "image/png"
      vars = Mongrel::HttpRequest.query_parse(request.params['QUERY_STRING'])
      File.open($dot_fn, 'w') do |f|
        f.write((["digraph wiki_map {"] +
        Line.find(:all).collect{|l| "  #{l.line}"} + ["}"]).join("\n"))
      end
      `dot -Tpng #{$dot_fn} -o #{$png_fn}`
      out.write File.read($png_fn)
    end
  end
end
      

server = Mongrel::HttpServer.new("127.0.0.1", "9999")
server.register("/", WikiLoggerHandler.new)
server.register("/show", WikiMapDisplayHandler.new)
server.register("/favicon.ico", Mongrel::Error404Handler.new(""))
server.run.join


