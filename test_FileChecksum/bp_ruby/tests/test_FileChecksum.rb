#BrowserPlus.FileAccess API Level Testing
#bugs can be found at bugs.browserplus.org

#!/usr/bin/env ruby

require 'digest/md5'

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/dist/share/service_testing/bp_service_runner.rb')
require 'uri'
require 'test/unit'
require 'open-uri'

 require File.join( File.dirname(File.expand_path(__FILE__) ), 'util' )
 if File.exist?('log.txt')
	File.delete('log.txt')
 end	
 $log = Logger.new('log.txt')

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
	  x = "Real checksum"
	  puts Digest::MD5.hexdigest(File.read(File.expand_path(File.join(curDir, "testFiles", "services.txt"))) )
	  @tid = 1
	  #testid : 1, 
	  Dir.glob(File.join(File.dirname(__FILE__), "cases", "*.json")).each do |f|
		json = JSON.parse(File.read(f))
		@file = json["file"]
		textfile_path = File.expand_path(File.join(curDir, "testFiles", @file))
        textfile_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + textfile_path
        assert_log( Digest::MD5.hexdigest(File.read(File.expand_path(File.join(curDir, "testFiles",@file))) ),  s.md5({"file" => textfile_uri}), $log, x, @tid )
		
		
		x = "Fake CS"
		@tid = @tid + 1
		#testid: 2, verify fake file
		@fake = json["file"]+(48+rand(80)).chr
		
		fake_path = File.expand_path(File.join(curDir, "testFiles", @fake))
        fake_uri = (( textfile_path[0] == "/") ? "file://" : "file:///" ) + fake_path
		begin
			got = s.md5({:file => fake_uri})
			assert_runTime(got, false, $log, x, @testid)
		rescue RuntimeError
			assert_runTime(got, true, $log, x, @testid)
		end
	  
	  end
	  
	}
end

end