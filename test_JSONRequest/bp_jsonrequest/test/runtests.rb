#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/dist/share/service_testing/bp_service_runner.rb')
require 'uri'
require 'test/unit'
require 'open-uri'
require 'webrick'
include WEBrick
require 'pp'

 require File.join( File.dirname(File.expand_path(__FILE__) ), 'util' )

 
 if File.exist?('log.txt')
	File.delete('log.txt')
 end
 

 $log = Logger.new('log.txt')






class TestJSONRequest < Test::Unit::TestCase
  def setup
    subdir = 'build/JSONRequest'
    if ENV.key?('BP_OUTPUT_DIR')
      subdir = ENV['BP_OUTPUT_DIR']
    end
    @cwd = File.dirname(File.expand_path(__FILE__))
	
	serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
							
    #@service = File.join(@cwd, "../src/#{subdir}")
	
	
	@server = HTTPServer.new(
                             :Port => 0,
                             :Logger => WEBrick::Log.new('/dev/null'),
                             :AccessLog => [ nil ],
                             :BindAddress => "127.0.0.1"
                   )
    @urlLocal = "http://localhost:#{@server[:Port]}/"
	
	
	@rubyrad = File.join(serviceLoc, "RubyInterpreter", "4.2.6")
	
	@service = File.join(serviceLoc, "JSONRequest", "1.0.13")
	puts @service
	
	@s = BrowserPlus::Service.new(@service, @rubyrad)
		@i = @s.allocate(@urlLocal)
  end
  
  def teardown
	@s.shutdown
  end



  #require whatever server you want to, mount it, and then verify that it has the same keys and values as in your doGET.json and doPOST.json
    def test_serverSH		
		#testcase 1.
		f = "./cases/case1.rb"
		require f
			temp = f
			temp[".rb"] = ".json"
			json = JSON.parse(File.read(temp)  )

			if json["url"]==""
				@url = @urlLocal
			else
				@url = json["url"]
			end
			
			@path1 = File.join(@cwd, "testFiles", json["send"])   # need to test send object ALSO
			puts "path is : #{@path1}"
		
			@server.mount("/", SH)
			@t = Thread.new() { @server.start }
			
			wantfile = temp
			wantfile[".json"] = ""
			want = JSON.parse(File.read( File.join(wantfile, "doGET.json")  ) )
			
			#keys are graham, nutella. values are crackers, and cupcakes.
			r = @i.get({"url" => @url})
			assert_log( want['graham'], r['graham'], $log, "case1", 1 )
			assert_log( want['nutella'], r['nutella'], $log, "case1", 1 )
			
			r = @i.get({"url" => @url, 'timeout'=>json["timeout"] })
			assert_log( want['graham'], r['graham'], $log, "case1", 2 )
			assert_log( want['nutella'], r['nutella'], $log, "case1", 2 )
			
			
			want = JSON.parse(File.read( File.join(wantfile, "doPOST.json")  ) )
			#keys
			r = @i.post({"url" => @url, 'send'=>@path1})
			assert_log( want['post'], r['post'], $log, "case1", 3)
			
			r= @i.post({"url" => @url, 'send'=>@path1, 'timeout'=>json["timeout"] } )
			assert_log( want['post'], r['post'], $log, "case1", 4 )
			
			#negetive test cases.
			@server.mount("/", OnlyPOST)
			
			begin
				r = @i.get( {"url" => @url  } )
				assert_runTime(r, false, $log, "case1, OnlyPOST runtime", 5)
			rescue RuntimeError
				assert_runTime(r, true, $log, "case1, OnlyPOST runtime", 5)
			end
			
			
			@server.mount("/", OnlyGET)
			begin
				r = @i.post( {"url" => @url  } )
				assert_runTime(r, false, $log, "case1, OnlyPOST runtime", 6)
			rescue RuntimeError
				assert_runTime(r, true, $log, "case1, OnlyPOST runtime", 6)
			end
			#testcase1 end
			
			
			
		   end
   
end
