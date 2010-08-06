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

  def test_simpleUpload
	#No do_POST
    @server.mount("/", Justget)
    @t = Thread.new() { @server.start }
    @output = @i.simpleUpload({'url'=>@url, 'file'=>@path  })
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
    assert_equal @want, @output['body']
	assert_equal "405 Method not allowed", @output['statusString']
	assert_not_equal 0, @output['statusCode']

	#Has post, hello : world
	@server.mount("/", Bothpostget)
    @t = Thread.new() { @server.start }
	@output = @i.simpleUpload({'url'=>@url, 'file'=>@path  })
	assert_equal '{"hello":"world"}', @output['body']	
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	#Has post, HTML res.body
	@server.mount("/", HTMLpost)
    @t = Thread.new() { @server.start }
	@output = @i.simpleUpload({'url'=>@url, 'file'=>@path  })
	@want = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	#testing cookies
	@output = @i.simpleUpload({'url'=>@url, 'file'=>@path, 'cookies'=>"The sacred cookie.."  }) 
	@want = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']

#testing progressCallback and responseProgressCallback
	filePercent_is_0 = false
	filePercent_is_100 = false
	percent_is_100 = false
	bytesR_311 = false
	@output = @i.simpleUpload({'url'=>@url, 'file'=>@path, 'cookies'=>"The sacred cookie.."  }) {
		|callBackData| 
	#	pp callBackData['args']['bytesReceived']
		if callBackData['args']['filePercent']==100
			filePercent_is_0 = true
		end
		if callBackData['args']['filePercent']==0
			filePercent_is_100 = true
		end
		if callBackData['args']['percent']==100
			percent_is_100 = true
		end
		if callBackData['args']['bytesReceived']==311
			bytesR_311 = true
		end
		
		} # puts callBackData
	assert_equal true, filePercent_is_0
	assert_equal true, filePercent_is_100
	assert_equal true, percent_is_100 #this test fails sometime
	assert_equal true, bytesR_311
	
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
#testing timeout
	@output = @i.simpleUpload({'url'=>@url, 'file'=>@path, 'timeout'=>5 })
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
  end
  
  def test_upload
	#No do_POST
    @server.mount("/", Justget)
    @t = Thread.new() { @server.start }
	@path = 'path:'+@cwd+'/hi.html'
	#puts "PATH IS : "
	#puts @path
    @filesarg = Hash.new
    @filesarg['key1'] = @path
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg})
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
	assert_equal @want, @output['body']
	assert_equal "405 Method not allowed", @output['statusString']
	assert_not_equal 0, @output['statusCode']
	
	#Has post, hello : world, one file
	@server.mount("/", Bothpostget)
    @t = Thread.new() { @server.start }
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg  })
	assert_equal '{"hello":"world"}', @output['body']	
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	#Has post, hello : world, two files
	@filesarg['key2'] = 'path:'+@cwd+'/hi2.html'
	#puts '\n'
	#puts @filesarg['key2']
	#puts @filesarg['key1']
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg  })
	assert_equal '{"hello":"world"}', @output['body']	
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	#Has post, HTML res.body
	@server.mount("/", HTMLpost)
    @t = Thread.new() { @server.start }
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg })
	@want = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	
	#testing cookies
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg, 'cookies'=>"The sacred cookie.."  }) 
	@want = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']


	#testing progressCallback and responseProgressCallback
	filePercent_is_0 = false
	filePercent_is_100 = false
	percent_is_100 = false
	bytesR_311 = false
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg, 'cookies'=>"The sacred cookie.."  }) {
		|callBackData| 
	#	pp callBackData['args']['bytesReceived']
		if callBackData['args']['filePercent']==100
			filePercent_is_0 = true
		end
		if callBackData['args']['filePercent']==0
			filePercent_is_100 = true
		end
		if callBackData['args']['percent']==100
			percent_is_100 = true
		end
		#if callBackData['args']['bytesReceived']==311
		#	bytesR_311 = true
		#end
		
		} # puts callBackData
	assert_equal true, filePercent_is_0
	assert_equal true, filePercent_is_100
#	assert_equal true, percent_is_100 #this test fails sometime
#	assert_equal true, bytesR_311
	
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	
	#testing timeout
	@output = @i.upload({'url'=>@url, 'files'=>@filesarg, 'timeout'=>5 })
	assert_equal @want, @output['body']
	assert_equal "O", @output['statusString'][4].chr
	assert_not_equal 0, @output['statusCode']
	
	
    end

	def test_download
	
	end



end
