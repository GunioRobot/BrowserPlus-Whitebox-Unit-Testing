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


class TestPStore < Test::Unit::TestCase
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
	
	@service = File.join(serviceLoc, "PStore", "1.0.10")
	puts @service
	
	@s = BrowserPlus::Service.new(@service, @rubyrad)
	@i = @s.allocate(@urlLocal)
  end
  
  def teardown
  
  end

  def test_Pstore
  
  #for all .json in cases
	Dir.glob(File.join(File.dirname(__FILE__), "cases", "*.json")).each do |f|
		json = JSON.parse( File.read( f )  ) 
		@k =  json["keys"].size()-1
		@keys = json["keys"]
		@values = json["values"]
		
		if @keys.size() != @values.size()
			assert_equal("keys and values don't have same size", "ERROR")
		end
		
		#set
		for i in 0..@k
			@i.set({'key'=> json["keys"][i], 'value'=>(json["values"])[i]   } )
			
		end
		
		#get
		for i in 0..@k
			x = @i.get({'key'=> @keys[i] })
			assert_log(@values[i], x, $log, "temp", 1 )
			
		end
		
		#keys
		@output = @i.keys()
		assert_log( @output.size(), @keys.size(), $log, "keys", 3)
		
		#clear
		@i.clear()
		@output = @i.keys()
		assert_log( 0, @output.size(), $log, "clear", 4)

	end


  end

  end