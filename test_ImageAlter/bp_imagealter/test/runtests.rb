#BrowserPlus API Level Testing
#bugs can be reported at bugs.browserplus.org

#!/usr/bin/env ruby

#ImageAlter
#Implements client side Image manipulation
#BrowserPlus.ImageAlter.transform({params}, function{}()) - Perform a set of transformations on an input image

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))),
                 "external/built/share/service_testing/bp_service_runner")
require 'uri'

clet = File.join(File.dirname(__FILE__), "..", "src", "build", "ImageAlter")

# arguments are a string that must match the test name
substrpat = ARGV.length ? ARGV[0] : ""

rv = 0
curDir = File.dirname(__FILE__)
BrowserPlus.run("#{curDir}/../src/build/ImageAlter") { |s|
  tests = 0
  successes = 0

  # now let's iterate through all of our tests
  Dir.glob(File.join(File.dirname(__FILE__), "cases", "*.json")).each do |f|
    next if substrpat && substrpat.length > 0 && !f.include?(substrpat)
    tests += 1 
    $stdout.write "#{File.basename(f, ".json")}: "
    $stdout.flush
    json = JSON.parse(File.read(f))
    # now let's change the 'file' param to a absolute URI
    p = File.join(File.dirname(__FILE__), "test_images", json["file"])
    p = File.expand_path(p)
    # now convert p into a file url
    json["file"] = ((p[0] == "/") ? "file://" : "file:///" ) + p

    took = Time.now
    r = s.transform(json)
    took = Time.now - took

    imgGot = nil
    begin
      imgGot = File.open(r['file'], "rb") { |oi| oi.read }
      wantImgPath = File.join(File.dirname(f),
                              File.basename(f, ".json") + ".out")
      raise "no output file for test!" if !File.exist? wantImgPath
      imgWant = File.open(wantImgPath, "rb") { |oi| oi.read }
      raise "output mismatch" if imgGot != imgWant
      # yay!  it worked!
      successes += 1
      puts "ok. (#{r['orig_width']}x#{r['orig_height']} -> #{r['width']}x#{r['height']} took #{took}s)"
    rescue => e
      err = e.to_s
      # for convenience, if the test fails, we'll *save* the output
      # image in xxx.got
      if imgGot != nil
        gotPath = File.join(File.dirname(f),
                            File.basename(f, ".json") + ".got")
        File.open(gotPath, "wb") { |oi| oi.write(imgGot) }
        err += " [left result in #{File.basename(gotPath)}]"
      end
      puts "fail (#{err} took #{took}s)"
    end
  end
  puts "#{successes}/#{tests} tests completed successfully"
  
  rv = successes == tests
}

exit rv

