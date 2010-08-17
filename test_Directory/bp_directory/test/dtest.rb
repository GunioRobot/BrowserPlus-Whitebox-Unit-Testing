#BrowserPlus.FileAccess API Level Testing
#bugs can be found at bugs.browserplus.org

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

#Directory
#Lets you list directory contents and invoke JavaScript .callbacks for the contained items.
class TestDirectory < Test::Unit::TestCase
  #SETUP
  def setup
    curDir = File.dirname(__FILE__)
    pathToService = File.join(curDir, "..", "src", "build", "Directory")
    @s = BrowserPlus::Service.new(pathToService)
    @path1 =  File.dirname(File.dirname(File.expand_path(__FILE__)))
    @path_testdir = @path1+"/test_directory/"
    @path_testdir_noP = @path1+"/test_directory"
    @path_testdir1 = @path1+"/test_directory/test_directory_1/"
    @test_directory = "file:///"+@path1+"/test_directory/"
    @test_directory_1 = "file:///"+@path1+"/test_directory/test_directory_1"
  end

  #TEARDOWN
  def teardown
    @s.shutdown
  end

  def Add(add_one_to_me)
    add_one_to_me = add_one_to_me + 1
    return add_one_to_me
  end

  #BrowserPlus.Directory.list({params}, function{}())
  #Returns a list in "files" of filehandles resulting from a non-recursive traversal of the arguments. No directory structure information is returned.
  def test_list 
	x = "test_list"
	
	@testid = 1
	#Directory/File does not exist, should return error <------------------------- BUG 212
	#x = @test_directory_1+"/this"
	#@list = Array.[]( x )
	#got = @s.list( { 'files'=>@list  } ) { |callback| puts callback }
	#puts got
	
	@testid = @testid + 1
    # 3 text files.
    @list = Array.[]( @test_directory_1 )
    want = {"files"=> [@path_testdir1+"bar1.txt", @path_testdir1+"bar2.txt", @path_testdir1+"bar3.txt"], "success"=>true }
    got = @s.list({ 'files' => @list })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #just one folder, no symbolic links
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir+"foo1.txt", @path_testdir+"foo2.txt", @path_testdir+"foo3.txt", @path_testdir+"sym_link", @path_testdir+"test_directory_1"],
      "success"=>true}
    got = @s.list({ 'files' => @list, "followLinks" => false })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #symbolic links
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir+"foo1.txt", @path_testdir+"foo2.txt", @path_testdir+"foo3.txt", @path1+"/sym_link", @path_testdir+"test_directory_1"],
      "success"=>true}
    got = @s.list({ 'files' => @list, "followLinks" => true })
    assert_log( want, got, $log, x, @testid )

    @testid = @testid + 1
    #mimetype => text/plain
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir+"foo1.txt", @path_testdir+"foo2.txt", @path_testdir+"foo3.txt"],
      "success"=>true}
    got = @s.list({ 'files' => @list, "followLinks" => false, "mimetypes" => ["text/plain"] })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #mimetype => image/jpeg ---- none present.
    @list = Array.[]( @test_directory )
    want = {"files"=> [],
      "success"=>true}
    got = @s.list({ 'files' => @list, "followLinks" => false, "mimetypes" => ["image/jpeg"] })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #size = 2
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir+"foo1.txt", @path_testdir+"foo2.txt"],
      "success"=>true}
    got = @s.list({ 'files' => @list, "followLinks" => true, "limit"=>2 })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #callback
    x = 1
    @list = Array.[]( @test_directory )
    got = @s.list({ 'files' => @list, "followLinks" => true, "limit"=>2 }, x = Add(x))
    assert_equal( 2, x )

  end


  #BrowserPlus.Directory.recursiveList({params}, function{}())
  #Returns a list in "files" of filehandles resulting from a recursive traversal of the arguments. No directory structure information is returned
  def test_recursiveList
	x = "recursive list"
	#Directory/File does not exist, should return error <--------------------------------- BUG 212
	#x = @test_directory_1+"/this"
	#@list = Array.[]( x )
	#got = @s.recursiveList( { 'files'=>@list  } )
	#puts got
	@testid = 1
	

    # 3 text files.
    @list = Array.[]( @test_directory_1 )
    want = {"files"=> [@path_testdir+"test_directory_1", @path_testdir+"test_directory_1/bar1.txt", @path_testdir+"test_directory_1/bar2.txt", @path_testdir+"test_directory_1/bar3.txt"], "success"=>true }
    got = @s.recursiveList({ 'files' => @list })
    assert_log( want, got, $log, x, @testid )

	
	@testid = @testid + 1
    #just one folder, no symbolic links
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir_noP, @path_testdir+"foo1.txt", @path_testdir+"foo2.txt", @path_testdir+"foo3.txt", @path_testdir+"sym_link", @path_testdir+"test_directory_1", @path_testdir+"test_directory_1/bar1.txt", @path_testdir+"test_directory_1/bar2.txt", @path_testdir+"test_directory_1/bar3.txt"],
      "success"=>true}
    got = @s.recursiveList({ 'files' => @list, "followLinks" => false })
    assert_log( want, got, $log, x, @testid )
	
	@testid = @testid + 1
    #symbolic links
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir_noP, @path_testdir+"foo1.txt", @path_testdir+"foo2.txt", @path_testdir+"foo3.txt", @path1+"/sym_link", @path1+"/sym_link/sym1.txt",@path_testdir+"test_directory_1", @path_testdir+"test_directory_1/bar1.txt", @path_testdir+"test_directory_1/bar2.txt", @path_testdir+"test_directory_1/bar3.txt"],
      "success"=>true}
    got = @s.recursiveList({ 'files' => @list, "followLinks" => true })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #mimetype => text/plain
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir+"foo1.txt", @path_testdir+"foo2.txt", @path_testdir+"foo3.txt", @path_testdir+"test_directory_1/bar1.txt", @path_testdir+"test_directory_1/bar2.txt", @path_testdir+"test_directory_1/bar3.txt"],
      "success"=>true}
    got = @s.recursiveList({ 'files' => @list, "followLinks" => false, "mimetypes" => ["text/plain"] })
    assert_log( want, got, $log, x, @testid )


	@testid = @testid + 1
    #mimetype => image/jpeg ---- none present.
    @list = Array.[]( @test_directory )
    want = {"files"=> [],
      "success"=>true}
    got = @s.recursiveList({ 'files' => @list, "followLinks" => false, "mimetypes" => ["image/jpeg"] })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #limit = 2
    @list = Array.[]( @test_directory )
    want = {"files"=> [@path_testdir_noP, @path_testdir+"foo1.txt"],
      "success"=>true}
    got = @s.recursiveList({ 'files' => @list, "followLinks" => true, "limit"=>2 })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #callback
    x = 1
    @list = Array.[]( @test_directory )
    got = @s.recursiveList({ 'files' => @list, "followLinks" => true, "limit"=>2 }, x = Add(x))
    assert_equal( 2, x )


  end

  #BrowserPlus.Directory.recursiveListWithStructure({params}, function{}())
  #Returns a nested list in "files" of objects for each of the arguments. An "object" contains the keys "relativeName" (this node's name relative to the specified directory), 
  #"handle" (a filehandle for this node), and for directories "children" which contains a list of objects for each of the directory's children. 
  #Recurse into directories.
  def test_recursiveListWithStructure
	@testid = 1
	x = "recursive list with structure"
  
	#Directory/File does not exist, should return error <--------------------------------- BUG 212
	#x = @test_directory_1+"/this"
	#@list = Array.[]( x )
	#got = @s.recursiveListWithStructure( { 'files'=>@list  } )
	#puts got

	@testid = @testid + 1
	# 3 text files.
    @list = Array.[]( @test_directory_1 )
    want = {"files"=>
        [{"handle"=>
           @path_testdir+"test_directory_1",
          "relativeName"=>"test_directory_1",
          "children"=>
           [{"handle"=>
              @path_testdir+"test_directory_1/bar1.txt",
             "relativeName"=>"test_directory_1/bar1.txt"},
            {"handle"=>
              @path_testdir+"test_directory_1/bar2.txt",
             "relativeName"=>"test_directory_1/bar2.txt"},
            {"handle"=>
              @path_testdir+"test_directory_1/bar3.txt",
             "relativeName"=>"test_directory_1/bar3.txt"}]}],
       "success"=>true}
    #want = {"files"=> [@path_testdir+"test_directory_1", @path_testdir+"test_directory_1/bar1.txt", @path_testdir+"test_directory_1/bar2.txt", @path_testdir+"test_directory_1/bar3.txt"], "success"=>true }
    got = @s.recursiveListWithStructure({ 'files' => @list })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #just one folder, no symbolic links
    @list = Array.[]( @test_directory )
    want = {"files"=>
        [{"handle"=>
           @path_testdir_noP,
          "relativeName"=>".",
          "children"=>
           [{"handle"=>
              @path_testdir+"foo1.txt",
             "relativeName"=>"./foo1.txt"},
            {"handle"=>
              @path_testdir+"foo2.txt",
             "relativeName"=>"./foo2.txt"},
            {"handle"=>
              @path_testdir+"foo3.txt",
             "relativeName"=>"./foo3.txt"},
            {"handle"=>
              @path_testdir+"sym_link",
             "relativeName"=>"./sym_link",
             "children"=>[]},
            {"handle"=>
              @path_testdir+"test_directory_1",
             "relativeName"=>"./test_directory_1",
             "children"=>
              [{"handle"=>
                 @path_testdir+"test_directory_1/bar1.txt",
                "relativeName"=>"./test_directory_1/bar1.txt"},
               {"handle"=>
                 @path_testdir+"test_directory_1/bar2.txt",
                "relativeName"=>"./test_directory_1/bar2.txt"},
               {"handle"=>
                 @path_testdir+"test_directory_1/bar3.txt",
                "relativeName"=>"./test_directory_1/bar3.txt"}]}]}],
       "success"=>true}
    got = @s.recursiveListWithStructure({ 'files' => @list, "followLinks" => false })
    assert_log( want, got, $log, x, @testid )
 
	@testid = @testid + 1   
    #mimetype => text/plain
    @list = Array.[]( @test_directory )
    want = {"files"=>
        [{"handle"=>@path1+"/.",
          "relativeName"=>".",
          "children"=>
           [{"handle"=>
              @path_testdir+"foo1.txt",
             "relativeName"=>"./foo1.txt"},
            {"handle"=>
              @path_testdir+"foo2.txt",
             "relativeName"=>"./foo2.txt"},
            {"handle"=>
              @path_testdir+"foo3.txt",
             "relativeName"=>"./foo3.txt"},
            {"handle"=>
              @path1+"/./test_directory_1",
             "relativeName"=>"./test_directory_1",
             "children"=>
              [{"handle"=>
                 @path_testdir+"test_directory_1/bar1.txt",
                "relativeName"=>"./test_directory_1/bar1.txt"},
               {"handle"=>
                 @path_testdir+"test_directory_1/bar2.txt",
                "relativeName"=>"./test_directory_1/bar2.txt"},
               {"handle"=>
                 @path_testdir+"test_directory_1/bar3.txt",
                "relativeName"=>"./test_directory_1/bar3.txt"}]}]}],
       "success"=>true}
    got = @s.recursiveListWithStructure({ 'files' => @list, "followLinks" => false, "mimetypes" => ["text/plain"] })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #mimetype => image/jpeg ---- none present.
    @list = Array.[]( @test_directory )
    want = {"files"=> [],
      "success"=>true}
    got = @s.recursiveListWithStructure({ 'files' => @list, "followLinks" => false, "mimetypes" => ["image/jpeg"] })
    assert_log( want, got, $log, x, @testid )

    #size = 2
    @list = Array.[]( @test_directory )
    want = {"files"=>
        [{"handle"=>
           @path_testdir_noP,
          "relativeName"=>".",
          "children"=>
           [{"handle"=>
              @path_testdir+"foo1.txt",
             "relativeName"=>"./foo1.txt"}]}],
       "success"=>true}
    got = @s.recursiveListWithStructure({ 'files' => @list, "followLinks" => true, "limit"=>2 })
    assert_log( want, got, $log, x, @testid )

	@testid = @testid + 1
    #function
    x = 1
    @list = Array.[]( @test_directory )
    got = @s.recursiveListWithStructure({ 'files' => @list, "followLinks" => true, "limit"=>2 }, x = Add(x))
  #  assert_equal( 2, x )


  end





  # XXX: test chunk and slice
end
