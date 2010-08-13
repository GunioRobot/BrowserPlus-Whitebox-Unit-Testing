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


class TestPublishSubscribe < Test::Unit::TestCase
  def setup
    @cwd = File.dirname(File.expand_path(__FILE__))
    @interpService = File.join(@cwd, "../src/build/RubyInterpreter")
	
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
  end
  
   
  def teardown
	@s.shutdown
  end



  def test_Pubsub
  
	#@i.addListener( {'receiver'=> , 'origin'=>@urlLocal }  )
	#@i.postMessage( {'data'=>3, 'targetOrigin'=>"*" }  )
  
  end
  
  def test_Other
	puts "this"
  
  end
  
end