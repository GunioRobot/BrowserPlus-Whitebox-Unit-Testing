#BrowserPlus.FileAccess API Level Testing
#bugs can be found at bugs.browserplus.org

#!/usr/bin/env ruby

require 'digest/md5'

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/dist/share/service_testing/bp_service_runner.rb')
require 'uri'
require 'test/unit'
require 'open-uri'

class TestFileAccess < Test::Unit::TestCase
  #SETUP
  def setup
    @cwd = File.dirname(File.expand_path(__FILE__))
	@interpService = File.join(@cwd, "../src/build/RubyInterpreter")
  end
  
  #TEARDOWN
  def teardown
  end

  #BrowserPlus.FileChecksum.md5({params}, function{}())
  #Generate an md5 checksum of a file.
  def test_file_checksum
    BrowserPlus.run(File.join(@cwd, "FileChecksum"), @interpService) { |s|
      curDir = File.dirname(__FILE__)
	  
	  puts Digest::MD5.hexdigest(File.read(File.expand_path(File.join(curDir, "services.txt"))) )
	  
	  #1. services.txt
      #textfile_path = File.expand_path(File.join(curDir, "testFiles", "services.txt"))
      #textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      #assert_equal "babc871bf6893c8313686e31cb87816a",  s.md5({:file => textfile_uri})
	  
	  
	  #1. services.txt
      textfile_path = File.expand_path(File.join(curDir, "services.txt"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_equal "babc871bf6893c8313686e31cb87816a",  s.md5({:file => textfile_uri})
	  
	  
	  #2. hi.html
	  textfile_path = File.expand_path(File.join(curDir, "hi.html"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_equal "6c57e6e704dbc69bc859a18358a00bad",  s.md5({:file => textfile_uri})
	  
	  #3. 2010INTERNS_ORIENTATION PRESO_REV 06
	  textfile_path = File.expand_path(File.join(curDir, "2010INTERNS_ORIENTATION\ PRESO_REV\ 06.pdf"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_equal "dedbfc81ca86bc44d65caf5319adc36a",  s.md5({:file => textfile_uri})

	  #4. browserplus-platform-289a944.zip
	  textfile_path = File.expand_path(File.join(curDir, "browserplus-platform-289a944.zip"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_equal "d83531d17b36d55a632fa1ad1e9d9a65",  s.md5({:file => textfile_uri})

	  #5. my_new_archive.tar.gz
	  textfile_path = File.expand_path(File.join(curDir, "my_new_archive.tar.gz"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_equal "b28c9ddf5d910bf1fd30f0b7eae6f442",  s.md5({:file => textfile_uri})
	  
	  #6. slice - should cause error...assert_raise
	  textfile_path = File.expand_path(File.join(curDir, "slice"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_raise(RuntimeError) { s.md5({:file => textfile_uri})  }
	  
	  #7 eclipse.exe
	  textfile_path = File.expand_path(File.join(curDir, "Eclipse.app"))
      textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
      assert_raise(RuntimeError) { s.md5({:file => textfile_uri})  }
		
		
    }
  end

  end