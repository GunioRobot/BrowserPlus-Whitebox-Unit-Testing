#!/usr/bin/env ruby
 
 require File.join( File.dirname(File.expand_path(__FILE__) ), 'util' )

 
 if File.exist?('log.txt')
	File.delete('log.txt')
 end
 

 $log = Logger.new('log.txt')

#BrowserPlus.FileAccess API Level Testing
#bugs can be found at bugs.browserplus.org

require File.join(File.dirname(File.expand_path(__FILE__)),
                  'external/built/share/service_testing/bp_service_runner.rb')

require 'uri'
require 'test/unit'
require 'open-uri'
require 'webrick'
include WEBrick
require 'pp'

require 'net/http'
require 'net/https'


#FileTransfer
#This service lets you upload or download files faster and easier than before.
class TestFileTransfer < Test::Unit::TestCase
	
  #SETUP
  def setup
    @server = HTTPServer.new(
                             :Port => 0,
                             :Logger => WEBrick::Log.new('/dev/null'),
                             :AccessLog => [ nil ],
                             :BindAddress => "127.0.0.1"
                   )
    @url_local = "http://localhost:#{@server[:Port]}/"
    @cwd = File.dirname(File.expand_path(__FILE__))
	@interpService = File.join(@cwd, "src/build/RubyInterpreter")
    serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
	@rad = File.join(serviceLoc, "FileTransfer", "1.1.1")
	@rubyrad = File.join(serviceLoc, "RubyInterpreter", "4.2.6")
    @s = BrowserPlus::Service.new(@rad)#, @rubyrad)
    @i = @s.allocate(@url_local)
	@path = @cwd+'/hi.html'
	@path22 = @cwd+'/log.txt'
	@want1 = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">
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
	
  end
  #TEARDOWN
  def teardown
    #@server.stop
    #@t.join
    @s.shutdown
  end


  def test_download
		Dir.glob(File.join(File.dirname(__FILE__), "cases_download", "*.rb")).each do |f|
			
			require f # Returns nil..?
			temp = f
			temp[".rb"] = ".json"

			json = JSON.parse(File.read(temp)  )
			if json["url"]==""
				@url = @url_local
			else
				@url = json["url"]
			end
			@path = File.join(@cwd, "testFiles", json["file"])
			
			wantfile = temp
			wantfile[".json"] = ""

			@want2 = File.read(File.join(wantfile, "want2.txt"))
			@want3 = File.read(File.join(wantfile, "want3.txt"))
			
			@timeout = json["timeout"]
			@cookies = json["cookies"]
			
				
			@testid = 0
	  
			@testid = @testid + 1
			#Justpost
			@server.mount("/", Justpost)
			@t = Thread.new() { @server.start }
			@output = @i.download({ 'url'=>@url  })
			assert_log("404 Not found", @output['statusString'], $log, f, @testid)
			assert_log(404, @output['statusCode'], $log, f, @testid)

			@testid = @testid + 1
			#Justget
			@server.mount("/", Justget)
			@t = Thread.new() { @server.start }
			@output = @i.download({ 'url'=>@url  })
			assert_log( 200, @output['statusCode'], $log, f, @testid)
			
			@testid = @testid + 1
			#Has post, hello : world
			@server.mount("/", Bothpostget)
			@t = Thread.new() { @server.start }
			@output = @i.download({'url'=>@url })	
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
			assert_log( 200, @output['statusCode'], $log, f, @testid)
			
			@testid = @testid + 1
			#Has post, HTML res.body
			@server.mount("/", HTMLpost)
			@t = Thread.new() { @server.start }
			@output = @i.download({'url'=>@url })
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
			assert_log( 200, @output['statusCode'], $log, f, @testid)
			
			@testid = @testid + 1
			#testing cookies
			@output = @i.download({'url'=>@url, 'cookies'=>@cookies }) 
			assert_log("200 OK", @output['statusString'], $log, f, @testid)
			assert_log( 200, @output['statusCode'], $log, f, @testid)
			
			@testid = @testid + 1
			#testing progressCallback and responseProgressCallback
			filePercent_is_0 = false
			filePercent_is_100 = false
			percent_is_100 = false
			bytesR_311 = false
			@output = @i.download({'url'=>@url, 'cookies'=>@cookies  }) {
				|callBackData| 
			#	pp callBackData
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
			assert_log( true, percent_is_100, $log, f, @testid) #this test fails sometime
			assert_log( true, bytesR_311, $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
			assert_log( 200, @output['statusCode'], $log, f, @testid)

			@testid = @testid + 1
			#testing timeout
			@output = @i.download({'url'=>@url, 'timeout'=>@timeout })
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
			assert_log( 200, @output['statusCode'], $log, f, @testid)
		end
  end


  #BrowserPlus.FileTransfer.simpleUpload({params}, function{}())
  #Upload a single file to a URL using POST. Return object value contains keys statusCode, statusString, headers, and body. 
  def test_simpleUpload
		Dir.glob(File.join(File.dirname(__FILE__), "cases_simpleUpload", "*.rb")).each do |f|
			require f # Returns nil..?
			temp = f
			temp[".rb"] = ".json"
	
			json = JSON.parse(File.read(temp)  )
			if json["url"]==""
				@url = @url_local
			else
				@url = json["url"]
			end
			@path = File.join(@cwd, "testFiles", json["file"])
			
			wantfile = temp
			wantfile[".json"] = ""

		
			@want2 = File.read(File.join(wantfile, "want2.txt"))
			@want3 = File.read(File.join(wantfile, "want3.txt"))
			
			@timeout = json["timeout"]
			@cookies = json["cookies"]
			@testid = 0
			
			@testid = @testid+1		
			#No do_POST
			@server.mount("/", Justget)
			@t = Thread.new() { @server.start }
			@output = @i.simpleUpload({'url'=>@url, 'file'=>@path  })
			#	#Justget.res
			assert_log( @want1, @output['body'], $log, f, @testid)
			assert_log( "405 Method not allowed", @output['statusString'], $log, f, @testid)

			@testid = @testid+1
			#Has post, hello : world
			@server.mount("/", Bothpostget)
			@t = Thread.new() { @server.start }
			@output = @i.simpleUpload({'url'=>@url, 'file'=>@path  })
			assert_log( @want2, @output['body'], $log, f, @testid)
		#	puts @want2	
		#	puts @output['body']
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
		
			@testid = @testid+1
			#Has post, HTML res.body
			@server.mount("/", HTMLpost)
			@t = Thread.new() { @server.start }
			@output = @i.simpleUpload({'url'=>@url, 'file'=>@path  })
			assert_log( @want3, @output['body'], $log, f, @testid)
			#puts @output['body']
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
		
			@testid = @testid+1
			#testing cookies
			@output = @i.simpleUpload({'url'=>@url, 'file'=>@path, 'cookies'=>@cookies  }) 
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)


			@testid = @testid+1
			#testing progressCallback and responseProgressCallback
			filePercent_is_0 = false
			filePercent_is_100 = false
			percent_is_100 = false
			bytesR_311 = false
			@output = @i.simpleUpload({'url'=>@url, 'file'=>@path, 'cookies'=>@cookies  }) {
				|callBackData| 
				#pp callBackData#['args']['bytesReceived']
				if callBackData['args']['filePercent']==100
					filePercent_is_0 = true
				end
				if callBackData['args']['filePercent']==0
					filePercent_is_100 = true
				end
				if callBackData['args']['percent']==100
					percent_is_100 = true
				end
		#		if callBackData['args']['bytesReceived']==311
		#			bytesR_311 = true
		#		end
				#puts "size = #{File.size(@path)} "
				} # puts callBackData
			assert_log( true, filePercent_is_0, $log, f, @testid)
			assert_log( true, filePercent_is_100, $log, f, @testid)
			assert_log( true, percent_is_100, $log, f, @testid) #this test fails sometime
		#	assert_equal true, bytesR_311
		
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)

		
			@testid = @testid+1
			#testing timeout
			@output = @i.simpleUpload({'url'=>@url, 'file'=>@path, 'timeout'=>@timeout })
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
		
		end
  end

  
  #BrowserPlus.FileTransfer.upload({params}, function{}())
  #Upload to a URL using POST and multi-part form data. Return object value contains keys statusCode, statusString, headers, and body.
  def test_upload
		Dir.glob(File.join(File.dirname(__FILE__), "cases_upload", "*.rb")).each do |f|
			require f # Returns nil..?
			temp = f
			temp[".rb"] = ".json"

			json = JSON.parse(File.read(temp)  )
			if json["url"]==""
				@url = @url_local
			else
				@url = json["url"]
			end
			@path = File.join(@cwd, "testFiles", json["file"])
			
			
			wantfile = temp
			wantfile[".json"] = ""
		
			@want2 = File.read(File.join(wantfile, "want2.txt"))
			@want3 = File.read(File.join(wantfile, "want3.txt"))
			
			@timeout = json["timeout"]
			@cookies = json["cookies"]
	
			@testid = 0

			@testid = @testid + 1
			#No do_POST
			@server.mount("/", Justget)
			@t = Thread.new() { @server.start }
			@path = 'path:'+@path
			
			@filesarg = Hash.new
			@filesarg['key1'] = @path
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg})
			assert_log( @want1, @output['body'], $log, f, @testid)
			assert_log( "405 Method not allowed", @output['statusString'], $log, f, @testid)

			
			@testid = @testid + 1
			#Has post, hello : world, one file
			@server.mount("/", Bothpostget)
			@t = Thread.new() { @server.start }
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg  })
			assert_log( @want2, @output['body'], $log, f, @testid)	
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
			
			
			@testid = @testid + 1
			#Has post, hello : world, two files
			@filesarg['key2'] = 'path:'+@cwd+'/testFiles'+'/hi2.html'
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg  })
			assert_log( @want2, @output['body'], $log, f, @testid)	
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
			
			
			@testid = @testid + 1
			#Has post, HTML res.body
			@server.mount("/", HTMLpost)
			@t = Thread.new() { @server.start }
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg })
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)

			
			@testid = @testid + 1
			#testing cookies
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg, 'cookies'=>@cookies  }) 
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)


			@testid = @testid + 1
			#testing progressCallback and responseProgressCallback
			filePercent_is_0 = false
			filePercent_is_100 = false
			percent_is_100 = false
			bytesR_311 = false
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg, 'cookies'=>@cookies  }) {
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
			#	if callBackData['args']['bytesReceived']==311
			#		bytesR_311 = true
			#	end
				
				} # puts callBackData
			assert_log( true, filePercent_is_0, $log, f, @testid)
			assert_log( true, filePercent_is_100, $log, f, @testid)
		#	assert_equal true, percent_is_100 #this test fails sometime
		#	assert_equal true, bytesR_311
			
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)
				
				
			@testid = @testid + 1
			#testing timeout
			@output = @i.upload({'url'=>@url, 'files'=>@filesarg, 'timeout'=>@timeout })
			assert_log( @want3, @output['body'], $log, f, @testid)
			assert_log( "200 OK", @output['statusString'], $log, f, @testid)

		
		end
	end

  
  end #END CLASS
  


