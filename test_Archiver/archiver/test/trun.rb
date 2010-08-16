#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

require 'rubygems'
require 'zip/zip'
require 'zip/ZipFileSystem'


class TestArchiver < Test::Unit::TestCase
  def setup
    curDir = File.dirname(__FILE__)
    @curDir = curDir
    pathToService = File.join(curDir, "..", "src", "build", "Archiver")
    @s = BrowserPlus::Service.new(pathToService)

  end
  
  def teardown
    @s.shutdown
  end

  def Add(add_one_to_me)
    add_one_to_me = add_one_to_me + 1
    return add_one_to_me
  end

  def test_archive
    puts "something"
	@letsTryThis = ''
    @letsTryThis = @curDir+"/.."+"/test_directory/test_directory_1" # I AM GOING TO HAVE TO USE THIS INSTEAD OF ABS PATH......
    puts @letsTryThis
    #
    #
    #@test_directory_1_uri = "file:///Users/ndmanvar/Desktop/test_Archiver/bp-archiver/test_directory/test_directory_1"
    @test_directory_1_uri = "file://"+@curDir+"/.."+"/test_directory/test_directory_1"
    #one directory - zip
	@test_directory_1_uri = 'path:'+"/Users/ndmanvar/Desktop/test_Archiver/bp-archiver/test_directory/test_directory_1"

    @output = @s.archive({ 'files'=> [@test_directory_1_uri], 'format'=>'zip' , 'recurse'=>false  }   )
    puts "WHY!?!?"

  end

  
  # XXX: test chunk and slice
end
