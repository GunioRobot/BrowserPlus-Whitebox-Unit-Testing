#!/usr/bin/env ruby
 require 'logger'
 
 require File.join( File.dirname(File.expand_path(__FILE__) ), 'util' )
 
 
 
 if File.exist?('log.txt')
	File.delete('log.txt')
 end
 
 
	
 $log = Logger.new('log.txt')

#BrowserPlus.FileAccess API Level Testing
#bugs can be found at bugs.browserplus.org

#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'
#require 'chilkat'
require 'rubygems'
require 'zip/zip'
require 'zip/ZipFileSystem'

#require 'rubygems'
require 'archive/tar/minitar'
include Archive::Tar
require 'tarruby'

#Archiver
#Lets you archive and optionally compress files and directories.
class TestArchiver < Test::Unit::TestCase
  #SETUP
  def setup
    curDir = File.dirname(__FILE__)
    @curDir = curDir
    pathToService = File.join(curDir, "..", "src", "build", "Archiver")
    @s = BrowserPlus::Service.new(pathToService)
	@curPath = @curDir+"/.."+"/test_directory/test_directory_1" # I AM GOING TO HAVE TO USE THIS INSTEAD OF ABS PATH......
    @testdir = File.expand_path(@curDir)+"/.."+"/test_directory"
	@testdirPath = "path:"+@testdir
    @test_directory_1_Path = "path:"+File.expand_path(@curDir)+"/.."+"/test_directory/test_directory_1"
  end

  #TEARDOWN  
  def teardown
    @s.shutdown
  end

  def Add(add_one_to_me)
    add_one_to_me = add_one_to_me + 1
    return add_one_to_me
  end

# BrowserPlus.Archiver.archive({params}, function{}())
# Lets you archive and optionally compress files and directories. (avaliable formats are zip, zip (uncompressed), tar, tar.gx, and tar.bz2)
  def test_zip
	x = "test_zip"
    #one directory - zip
    @output = @s.archive({ 'files'=> [@test_directory_1_Path], 'format'=>'zip' , 'recurse'=>false  }   )
   
    @testid = 1
   #testid: 1, open zip..compare files name/contents to original
   Zip::ZipFile.open(@output['archiveFile']) {
      |zipfile|
      want = File.open(@curPath+"/bar1.txt", "rb") { |f| f.read }
      got = zipfile.read("test_directory_1/bar1.txt")
      assert_log( want, got, $log, x, @testid)

      want = File.open(@curPath+"/bar2.txt", "rb") { |f| f.read }
      got = zipfile.read("test_directory_1/bar2.txt")
      assert_log( want, got, $log, x, @testid)

      want = File.open(@curPath+"/bar3.txt", "rb") { |f| f.read }
      got = zipfile.read("test_directory_1/bar3.txt")
	  assert_log( want, got, $log, x, @testid)

   }
   File.delete(@output['archiveFile'])
   
	@testid = @testid + 1   
    #testid: 2, two files - zip
    @output = @s.archive({'files'=> [@test_directory_1_Path + "/bar1.txt", @test_directory_1_Path + "/bar2.txt"], 'format'=>'zip'  , 'recurse'=>false   })
    Zip::ZipFile.open(@output['archiveFile']) {
        |zipfile|
        want = File.open(@curPath+"/bar1.txt", "rb") { |f| f.read }
        got = zipfile.read("bar1.txt")
        assert_log( want, got, $log, x, @testid)

        want = File.open(@curPath+"/bar2.txt", "rb") { |f| f.read }
        got = zipfile.read("bar2.txt")
        assert_log( want, got, $log, x, @testid)
#
        want = File.open(@curPath+"/bar2.txt", "rb") { |f| f.read }
        got = zipfile.read("bar2.txt")
        assert_log( want, got, $log, x, @testid)    }
    File.delete(@output['archiveFile'])
	
	
    #still need to add test cases that test: followLinks, recurse, progressCallback

	@output = @s.archive({ 'files'=>[@testdirPath], 'format'=>'zip', 'recurse'=>true  })
	
	   
   Zip::ZipFile.open(@output['archiveFile']) {
      |zipfile|
		puts zipfile
		q = zipfile.read("test_directory/test_directory_1/bar1.txt")
		puts q
		puts zipfile.read("test_directory/foo1.txt")
		

		}

  end

	#still working on tar...
  def test_tar
	x = "test_tar"
	@output = @s.archive({ 'files'=> [@test_directory_1_Path], 'format'=>'tar' , 'recurse'=>false  }   )
	#puts @output['archiveFile']
	
	@testid= 1
	Tar.open(@output['archiveFile'], File::RDONLY, 0644, Tar::GNU | Tar::VERBOSE) do |tar|
      while tar.read # or 'tar.each do ...'
        #puts tar.pathname
		
		
       # tar.print_long_ls

        if tar.reg? && tar.pathname!="test_directory_1/.DS_Store" # regular file
          tar.extract_file('test')
		  want = File.read(File.join(@testdir, tar.pathname))
		  puts tar.pathname
		  #asserting bar1,2,3 from tar file is same as original bar1,2,3
		  assert_log( want, File.read('test'), $log, x, @testid)
        end
      end

      ##if extract all files
      #tar.extract_all
    end


    ##for gzip archive
    #Tar.gzopen('foo.tar.gz', ...

    ##for bzip2 archive
    #Tar.bzopen('foo.tar.bz2', ...
  
  
  
  end
  # XXX: test chunk and slice
end
