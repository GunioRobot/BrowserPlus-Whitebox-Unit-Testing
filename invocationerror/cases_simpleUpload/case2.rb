#!/usr/bin/env ruby
#servers


require 'test/unit'
require 'open-uri'
require 'webrick'
include WEBrick
require 'pp'

class Justget < HTTPServlet::AbstractServlet
  def do_GET(req,res)
    res.body = '{"cinnamon":"toast_crunch"}'
  end 
	puts $i
end

class Justpost < HTTPServlet::AbstractServlet
  def do_POST(req,res)
    res.body = '{"honey":"bunchesofoats"}'
  end 
end

class Bothpostget < HTTPServlet::AbstractServlet
  def do_GET(req,res)
    res.body = '{"cinnamon":"toast_crunch"}'
  end 
  def do_POST(req,res)
    res.body = '{"hello":"world"}'
  end 
end

class HTMLpost < HTTPServlet::AbstractServlet
  def do_GET(req,res)
    res.body = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
  end 
  def do_POST(req,res)
    res.body = "<html>

<head>
<title> favorites / bookmark title goes here </title>
</head>

<body bgcolor=\"white\" text=\"blue\">

<h1> My first page </h1>

This is my first web page and I can say anything I want in here - I do that by putting text or images in the body section - where I'm typing right now :)

</body>

</html>"
  end 
end
