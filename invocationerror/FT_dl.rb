#!/usr/bin/env ruby

require File.join(File.dirname(File.expand_path(__FILE__)),
                  'external/built/share/service_testing/bp_service_runner.rb')

#require 'uri'

require 'test/unit'
require 'open-uri'

# let's set up a little itty bitty webserver
#!/usr/bin/env ruby
require 'webrick'
include WEBrick
require 'pp'

class Justget < HTTPServlet::AbstractServlet
  def do_GET(req,res)
    res.body = '{"cinnamon":"toast_crunch"}'
  end 

end

class Justpost < HTTPServlet::AbstractServlet
  def do_POST(req,res)
    res.body = '{"fruit":"loops"}'
  end
  
end


class Bothpostget < HTTPServlet::AbstractServlet
  def do_GET(req,res)
    res.body = '{"cinnamon":"toast_crunch"}'
  end 
  def do_POST(req,res)
    res.body = '{"hello":"world"}'
  end 
end

class HTMLpost < HTTPServlet::AbstractServlet
  def do_GET(req,res)
    res.body = '{"cinnamon":"toast_crunch"}'
  end 
  def do_POST(req,res)
    res.body = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
  end 
end


# and we'll define our tests
class TestFileTransfer < Test::Unit::TestCase
  def setup
    @server = HTTPServer.new(
                             :Port => 0,
                             :Logger => WEBrick::Log.new('/dev/null'),
                             :AccessLog => [ nil ],
                             :BindAddress => "127.0.0.1"
                   )
    @url = "http://localhost:#{@server[:Port]}/"
#	puts "URL:"
#	puts @url
   

    @cwd = File.dirname(File.expand_path(__FILE__))
	@interpService = File.join(@cwd, "src/build/RubyInterpreter")
	
	

    serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
	@rad = File.join(serviceLoc, "FileTransfer", "1.1.1")
	@rubyrad = File.join(serviceLoc, "RubyInterpreter", "4.2.6")
    @s = BrowserPlus::Service.new(@rad)#, @rubyrad)
    @i = @s.allocate(@url)
	
	@path = @cwd+'/hi.html'
  end
  
  def teardown
    @server.stop
    #@t.join
    @s.shutdown
  end

  def test_download
	  @server.mount("/", Justpost)
    @t = Thread.new() { @server.start }
    @output = @i.download({'url'=>@url   })
	#puts "BODY: "#	puts @output['body']
	@want = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">
<HTML>
  <HEAD><TITLE>Method Not Allowed</TITLE></HEAD>
  <BODY>
    <H1>Method Not Allowed</H1>
    unsupported method `POST'.
    <HR>
    <ADDRESS>
     WEBrick/1.3.1 (Ruby/1.8.7/2009-06-12) at
     localhost:#{@server[:Port]}
    </ADDRESS>
  </BODY>
</HTML>\n"
    #assert_equal @want, @output['body']
	
	#why is @output['fileHandle']=nil ?????? v4/v5?
	puts "FILEHANDLE : "
	puts @output['fileHandle']
	puts "HEADERS : "
	puts @output['headers']
	assert_equal "404 Not found", @output['statusString']
	assert_not_equal 0, @output['statusCode']
	
	puts "\n here:"
	puts @output
	puts 'again: '
	puts @output['fileHandle']
  end




end
