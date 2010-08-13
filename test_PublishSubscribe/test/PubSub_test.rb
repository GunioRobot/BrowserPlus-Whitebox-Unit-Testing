#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

require 'webrick'
include WEBrick
require 'pp'

class TestFileAccess < Test::Unit::TestCase
  def setup
		serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
	@rad = File.join(serviceLoc, "PublishSubscribe", "1.0.0")
	
    
	@rubyrad = File.join(serviceLoc, "RubyInterpreter", "4.2.6")


  end
  
  def teardown
    #@s.shutdown
  end


  def test_get
	BrowserPlus.run(@rad, @rubyrad){ |s| 
		s.postMessage({'data'=>"string", 'targetOrigin'=>"*"})
	
		}
  
	#output = @s.postMessage({'data'=>"string", 'targetOrigin'=>"http://locahost/dest/date.php"})
	 # @s.addListener()

  end

  # XXX: test chunk and slice
end
