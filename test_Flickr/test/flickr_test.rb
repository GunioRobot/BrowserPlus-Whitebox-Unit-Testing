#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner.rb')

require 'uri'

require 'test/unit'
require 'open-uri'

# let's set up a little itty bitty webserver
#!/usr/bin/env ruby
require 'webrick'
include WEBrick
require 'pp'





# and we'll define our tests
class FlickrUploader < Test::Unit::TestCase
  def setup
    
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
	
	@service = File.join(serviceLoc, "PublishSubscribe", "1.0.0")

	
	@s = BrowserPlus::Service.new(@service, @rubyrad)
	@i = @s.allocate(@urlLocal)
	@rad = File.join(serviceLoc, "FlickrUploader", "2.0.14")
	@rubyrad = File.join(serviceLoc, "RubyInterpreter", "4.2.6")
    @s = BrowserPlus::Service.new(@rad, @rubyrad)
    @i = @s.allocate(@url)
  end
  
  def teardown
  #    @s.shutdown
  end

  def test_one
#	x = @s.check_auth()
 #   puts x
#	BrowserPlus.run(@rad, @rubyrad) {|s|
	
#	x = s.check_auth()
	
#	}
	x = @i.check_auth()
   
   
  end
  
     
   
end
