#BrowserPlus.FileAccess API Level Testing
#bugs can be found at bugs.browserplus.org

#!/usr/bin/env ruby

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'

# FileAccess
# -> Access the contents of files that the user has selected.
class TestFileAccess < Test::Unit::TestCase
  #SETUP
  def setup
    curDir = File.dirname(__FILE__)
    pathToService = File.join(curDir, "..", "src", "build", "FileAccess")
    @s = BrowserPlus::Service.new(pathToService)

    @binfile_path = File.expand_path(File.join(curDir, "service.bin"))
    @binfile_uri = (( @binfile_path[0] == "/") ? "file://" : "file:///" ) + @binfile_path

    @textfile_path = File.expand_path(File.join(curDir, "services.txt"))

    @new_path = File.expand_path(File.join(curDir, "new.txt"))
    @new_uri = (( @new_path[0] == "/") ? "file://" : "file:///" ) + @new_path
    @textfile_uri = (( @textfile_path[0] == "/") ? "file://" : "file:///" ) + @textfile_path
  end
  
  #TEARDOWN
  def teardown
    @s.shutdown
  end

  def Add(add_one_to_me)
    add_one_to_me = add_one_to_me + 1
    return add_one_to_me
  end

#BrowserPlus.FileAccess.read({params}, function{}())
#Read the contents of a file on disk returning a string. If the file contains binary data an error will be returned
  def test_read
    # a simple test of the read() function, read a text file and a binary file
    want = File.open(@textfile_path, "rb") { |f| f.read }
    got = @s.read({ 'file' => @textfile_uri })
    assert_equal want, got

    # read() doesn't support binary data!  assert an exception is raised
    assert_raise(RuntimeError) { got = @s.read({ 'file' => @binfile_uri }) }

    # partial read
    want = File.open(@textfile_path, "rb") { |f| f.read(25) } 
    got = @s.read({ 'file' => @textfile_uri, 'size' => 25 })
    assert_equal want, got

    # partial read with offset
    want = File.open(@textfile_path, "rb") { |f| f.read(25) }[5, 20]
    got = @s.read({ 'file' => @textfile_uri, 'size' => 20, 'offset' => 5 })
    assert_equal want, got
	
    # ensure out of range errors are raised properly 
    assert_raise(RuntimeError) { @s.read({ 'file' => @textfile_uri, 'offset' => 1024000 }) }
    	
    # read with offset set at last byte of file
    want = ""
    got = @s.read({ 'file' => @textfile_uri, 'offset' => File.size(@textfile_path) }) 
    assert_equal want, got
	
	# ensure errors are raised properly for negetive offset
	assert_raise(RuntimeError) { @s.read({ 'file' => @textfile_uri, 'size' => 10, 'offset' => -15 })  }
		
#####read with size 0 <---------------------------------- BUG 208
	#got = @s.read({ 'file' => @textfile_uri, 'size' => 0, 'offset' => 0 })
	#want = ""
	#assert_equal want, got
	
    #function
    x = 1
    got = @s.read({ 'file' => @textfile_uri }, x = Add(x))
    assert_equal 2, x
	
  end

#BrowserPlus.FileAccess.getURL({params}, function{}())
#Get a localhost url that can be used to attain the full contents of a file on disk. 
  def test_geturl
	#use geturl to read entire file
    want = File.open(@textfile_path, "rb") { |f| f.read }
    url = @s.getURL({ 'file' => @textfile_uri })
    got = open(url) { |f| f.read }
    assert_equal want.gsub("\r\n","\n"), got.gsub("\r\n","\n")

    #function
    x = 1
    url = @s.getURL({ 'file' => @textfile_uri }, x = Add(x))
    got = open(url) { |f| f.read }
    assert_equal 2, x

  end
  
#BrowserPlus.FileAccess.slice({params}, function{}())
#Given a file and an optional offset and size, return a new file whose contents are a subset of the first.
  def test_slice

	#read entire file, no offset or size
    want = File.open(@textfile_path, "rb") { |f| f.read }
    got = @s.slice({ 'file' => @textfile_uri})
    got = open(got) { |f| f.read }
    assert_equal want, got

	#slice with offset of 5 and size of 20
    want = File.open(@textfile_path, "rb") { |f| f.read(25) }[5, 20]
    got = @s.slice({ 'file' => @textfile_uri, 'offset' => 5, 'size' => 20})
    got = open(got) { |f| f.read(25) }
    assert_equal want, got

	# slice a binary file --- should raise Runtime error? <------------------- BUG 213
	#assert_raise(RuntimeError) 
	# got = @s.slice({ 'file' => @binfile_uri, 'offset' => 5, 'size' => 20 }) 
	# puts got

    #Why is out-of-range runtime error not occurring in @s.slice as does in @s.read <------------------- BUG 209
    #assert_raise(RuntimeError) { @s.slice({ 'file' => @textfile_uri, 'offset' => 1024000 }) }
	
	
	#offset set at last byte, should return nothing ("") 
    want = ""
    got = @s.slice({ 'file' => @textfile_uri, 'offset' => File.size(@textfile_path) })
    got = open(got) { |f| f.read() }
    assert_equal want, got
    
    #function
    x = 1
    got = @s.slice({ 'file' => @textfile_uri}, x = Add(x))
    got = open(got) { |f| f.read }
    assert_equal 2, x

  end

  #BrowserPlus.FileAccess.chunk({params}, function{}())
  #Get a vector of objects that result from chunking a file. 
  #The return value will be an ordered list of file handles with each successive file representing a different chunk
  def test_chunk
	#chunnksize => 5000
    @allchunks = @s.chunk( { 'file' => @textfile_uri, 'chunkSize' => 5000  } )

    got = open(@allchunks[0]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[0, 5000]
    assert_equal want, got

    got = open(@allchunks[1]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[5000, 5000]
    assert_equal want, got

    got = open(@allchunks[2]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[10000, 5000]
    assert_equal want, got

    got = open(@allchunks[3]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[15000, 5000]
    assert_equal want, got

    got = open(@allchunks[4]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[20000, 5000]
    assert_equal want, got

    got = open(@allchunks[5]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[25000, 5000]
    assert_equal want, got

    got = open(@allchunks[6]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[30000, 5000]
    assert_equal want, got

    got = open(@allchunks[7]) { |f| f.read() }
    want = File.open(@textfile_path, "rb") { |f| f.read() }[35000, 5000]
    assert_equal want, got


	#Chunksize => 0 should not cause invocation error, should cause Runtime error? <------------------------ BUG 213
	#@allchunks = @s.chunk({ 'file' => @textfile_uri, 'chunkSize'=>0    }  )
	
	#Chunksize => 1024000
	@allchunks = @s.chunk({ 'file' => @textfile_uri, 'chunkSize'=>1024000    }  )
	got = open(@allchunks[0]) { |f| f.read() }
	want = File.open(@textfile_path, "rb") { |f| f.read() }[0, 1024000]
	assert_equal want, got
	
	#Negetive chunksize returns whole file. <------------------------ BUG 211
	#@allchunks = @s.chunk({ 'file' => @textfile_uri, 'chunkSize'=>-5000    }  )
	#got = open(@allchunks[0]) { |f| f.read() }
	#want = File.open(@textfile_path, "rb") { |f| f.read() }[0, 5000]
	#assert_equal want, got
	

    #function
    x = 1
    @allchunks = @s.chunk( { 'file' => @textfile_uri, 'chunkSize' => 5000  }, x = Add(x) )
    assert_equal 2, x

  end

  # XXX: test chunk and slice
end
