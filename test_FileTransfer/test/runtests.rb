#!/usr/bin/env ruby


require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                  'external/built/share/service_testing/bp_service_runner')
require 'uri'
require 'test/unit'
require 'open-uri'


class TestFileTransfer < Test::Unit::TestCase
  def setup
    curDir = File.dirname(__FILE__)
    pathToService = File.join(curDir, "..", "1.1.1")
puts pathToService
   # puts pathToService
      @s = BrowserPlus::Service.new(pathToService)
      @i = @s.allocate "http://localhost/dest/allocate.html"




    @binfile_path = File.expand_path(File.join(curDir, "service.bin"))
    @binfile_uri = (( @binfile_path[0] == "/") ? "file://" : "file:///" ) + @binfile_path

    @textfile_path = "path:" + File.expand_path(File.join(curDir, "servicesUploader.txt"))
    @textfile_uri = (( @textfile_path[0] == "/") ? "file://" : "file:///" ) + @textfile_path

    @textfile_path_1 = File.expand_path(File.join(curDir) )
    @textfile_uri_1 = (( @textfile_path[0] == "/") ? "file://" : "file:///" ) + @textfile_path_1

    @new_path = File.expand_path(File.join(curDir, "new.txt"))
    @new_uri = (( @new_path[0] == "/") ? "file://" : "file:///" ) + @new_path

  end

  def teardown
   # @s.shutdown
  end

  def Add(add_one_to_me)
    add_one_to_me = add_one_to_me + 1
    return add_one_to_me
  end

def test_me
  puts "TEST:"

end

def test_simpleUpload




    #1. URL not found test
    @urlarg = "http://localhost/dest/fake.php"
    @URL_notFound_body = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL /dest/fake.php was not found on this server.</p>
</body></html>\n"
   @output = @i.simpleUpload({'url'=>@urlarg, 'file'=>@textfile_path})

    assert_equal @URL_notFound_body, @output['body']
    #puts @output['statusString'][4].chr
    assert_equal "N", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.



    #2. php file exists - TDavid's Very First PHP Script
    @urlarg = "http://localhost/dest/date.php"
   
    @output = @i.simpleUpload({'url'=>@urlarg, 'file'=>@textfile_path})
    @want = "<html>

<head>
<title>Example #1 TDavid's Very First PHP Script ever!</title>
</head>
<? print(Date(\"1 F d, Y\")); ?>

<body>
</body>
</html>\n\n"

    assert_equal @want, @output['body']
    assert_equal "O", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.


    #3. Cookies.
    @urlarg = "http://localhost/dest/date.php"
    @output = @i.simpleUpload({'url'=>@urlarg, 'file'=>@textfile_path, 'cookies'=>"This is the respected Cookie!"})

    assert_equal @want, @output['body']
    assert_equal "O", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.

    #4. progressCallback - this probably is not correct.
    @t = 1
    @output = @i.simpleUpload({'url'=>@urlarg, 'file'=>@textfile_path, 'cookies'=>"This is the respected Cookie!", 'progressCallback'=> @t =Add(@t)})




  end

  def test_upload

    # 1. url not found
    @urlarg = "http://localhost/dest/fake.php"
   #  @urlarg = "http://browserplus.org/misc/upload.php"
    #@URL_notFound_body = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">"
    @filesarg = Hash.new
    @filesarg['key1'] = @textfile_path

    @output = "OUTPUT YO"
    @output = @i.upload({'url'=>@urlarg, 'files'=>@filesarg})
   # puts @output
 @URL_notFound_body = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL /dest/fake.php was not found on this server.</p>
</body></html>\n"
    assert_equal @URL_notFound_body, @output['body']
    assert_equal "N", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.


    #2. url found, php file exsists, php file exists - TDavid's Very First PHP Script
    @urlarg = "http://localhost/dest/date.php"
    @want = "<html>

<head>
<title>Example #1 TDavid's Very First PHP Script ever!</title>
</head>
<? print(Date(\"1 F d, Y\")); ?>

<body>
</body>
</html>\n\n"
    @output = @i.upload({'url'=>@urlarg, 'files' => @filesarg   })
    #puts @output
    assert_equal @want, @output['body']
    assert_equal "O", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.


    #3. two files in 'files'
    @filesarg['key2'] = @textfile_path
    @output = @i.upload({'url'=>@urlarg, 'files'=> @filesarg   })
#    puts "START: "
#    puts @output
#    puts ":END"
    assert_equal @want, @output['body']
    assert_equal "O", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.

    #4. two files, and cookies
    @output = @i.upload({'url'=>@urlarg, 'files'=> @filesarg, 'cookies'=>"This is the respected Cookie!"   })
    assert_equal @want, @output['body']
    assert_equal "O", @output['statusString'][4].chr #statusString="404 Not Found", therefore making sure (N)ot Found
    assert_not_equal 0, @output['statusCode'] #means status code was set to a number, and not left uninitialized.




  end

  def test_crossd
    @b = @s.allocate "http://biteme.org/index.html"
    @urlarg = "http://localhost/dest/date.php"
    #@output1 = @b.simpleUpload({'url'=> @urlarg, 'file'=> @textfile_path })




  end



 

  



  # XXX: test chunk and slice
end
