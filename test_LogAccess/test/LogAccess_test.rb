#BrowserPlus API Level Testing
#bugs can be reported at bugs.browserplus.org

#!/usr/bin/env ruby

 require 'logger'
 
 require File.join( File.dirname(File.expand_path(__FILE__) ), 'util' )
 
 
 
 if File.exist?('log.txt')
	File.delete('log.txt')
 end
 
 
	
 $log = Logger.new('log.txt')

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

require 'webrick'
include WEBrick
require 'pp'

#LogAccess
#Lets you get file handles for BrowserPlus log files from a webpage.
class TestLogAccess < Test::Unit::TestCase
  #SETUP
  def setup
	@server = HTTPServer.new(
                             :Port => 0,
                             :Logger => WEBrick::Log.new('/dev/null'),
                             :AccessLog => [ nil ],
                             :BindAddress => "127.0.0.1"
                   )
    @url = "http://localhost:#{@server[:Port]}/"
	@url = "http://yahoo.com/fake.html"

    curDir = File.dirname(__FILE__)
	serviceLoc = File.join(ENV["HOME"], "Library", "Application Support",
                            "Yahoo!", "BrowserPlus", "Corelets")
	@rad = File.join(serviceLoc, "LogAccess", "1.0.0")
    @s = BrowserPlus::Service.new(@rad)
	 @i = @s.allocate(@url)

  end
  
  #TEARDOWN
  def teardown
    #@s.shutdown
  end

  #BrowserPlus.LogAccess.get({params}, function{}())
  #Returns a list in "files" of filehandles associated with BrowserPlus logfiles.
  def test_get
	@x = @i.get()
	@bpnapapi = ENV["HOME"]+'/Library/Application Support/Yahoo!/BrowserPlus/2.9.2/96769036-6746-4CAB-AED4-0459DD836D5A/bpnpapi.log'
	@BplusCore = ENV["HOME"]+'/Library/Application Support/Yahoo!/BrowserPlus/2.9.2/96769036-6746-4CAB-AED4-0459DD836D5A/BrowserPlusCore.log'
	@testid = 1
	assert_log( @bpnapapi, @x[0], $log, "bpnpapi.log", @testid)
	
	@testid = 2
	assert_log( @BplusCore, @x[1], $log, "bpnpapi.log", @testid)

  end

  # XXX: test chunk and slice
end
