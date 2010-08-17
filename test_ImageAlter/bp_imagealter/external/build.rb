#!/usr/bin/env ruby

require "bakery/ports/bakery"

$order = {
  :output_dir => File.join(File.dirname(__FILE__), "built"),
  :packages => [
                "zlib",
                "libpng",
                "jpeg",
                "GraphicsMagick",
                "service_testing"
               ],
  :verbose => true
}

b = Bakery.new $order
b.build
