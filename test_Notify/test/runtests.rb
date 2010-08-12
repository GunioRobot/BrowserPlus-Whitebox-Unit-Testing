#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

class TestFileAccess < Test::Unit::TestCase
  def setup
    curDir = File.dirname(__FILE__)
    pathToService = File.join(curDir, "..", "..", "BrowserPlus", "browserplus-platform-12b5751"   , "services", "build", "Notify", "Main", "Notify")
    #puts pathToService
    @s = BrowserPlus::Service.new(pathToService)

    @binfile_path = File.expand_path(File.join(curDir, "service.bin"))
    @binfile_uri = (( @binfile_path[0] == "/") ? "file://" : "file:///" ) + @binfile_path

    @textfile_path = File.expand_path(File.join(curDir, "services.txt"))
    @textfile_uri = (( @textfile_path[0] == "/") ? "file://" : "file:///" ) + @textfile_path

    @new_path = File.expand_path(File.join(curDir, "new.txt"))
    @new_uri = (( @new_path[0] == "/") ? "file://" : "file:///" ) + @new_path

  end
  
  def teardown
    @s.shutdown
  end

  def Add(add_one_to_me)
    add_one_to_me = add_one_to_me + 1
    return add_one_to_me
  end

  def test_show
    # a simple test of the read() function, read a text file and a binary file
    x = 1
    y = 1
    
    
    assert_equal x, y

    @output = @s.show({'title'=>"TITLE", 'message'=>"MESSAGESDFJ:KSFJ:KSDJFK:LSDJF:KLSJFK:LSJF:KLSDJFK:LSDJF:KLSJF:K"})

    puts "OUTPUT is : "
    puts @output



  end

  # XXX: test chunk and slice
end
