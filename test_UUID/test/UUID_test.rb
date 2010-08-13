#BrowserPlus API Level Testing
#bugs can be reported at bugs.browserplus.org

#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

require 'webrick'
include WEBrick
require 'pp'

#UUID
#Generate universally unique identifiers.
class TestUUID < Test::Unit::TestCase
  #SETUP
  def setup
		serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
	@rad = File.join(serviceLoc, "UUID", "1.0.4")
	
    @s = BrowserPlus::Service.new(@rad)
  end

  #TEARDOWN
  def teardown
    @s.shutdown
  end

  #BrowserPlus.UUID.get({params}, function{}())
  #generate a new UUID. Will return a string representation of a universally unique identifier.
  def test_get
	@x = Array.new()
	for i in 0..1000
	   @x[i] = d = @s.get()
	   for q in 0..(i-1)
			if d==@x[q]
				assert_equal 1, 2
			end
	   
	   end
	end

  

  end

  # XXX: test chunk and slice
end
