#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

require 'webrick'
include WEBrick
require 'pp'

class TestMotion < Test::Unit::TestCase
  def setup
		serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
	@rad = File.join(serviceLoc, "Motion", "0.1.9")
	
    @s = BrowserPlus::Service.new(@rad)


  end
  
  def teardown
    @s.shutdown
  end


  def test_get
	@output = @s.Coords({ 'method'=> "mouse"  })
	puts @output

  end

end
