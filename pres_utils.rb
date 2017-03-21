require 'yaml'
require 'tempfile'

module PresUtils
  mattr_reader :debug, :cache, :red, :print, :debug, :d, :timer, :delta

  @@red = -> a {"\033[31m#{a}\033[0m"}
  @@print = $stdout.method(:puts)
  @@debug = -> msg, a { puts (msg >>+ red);  puts a.pretty_inspect; a }.curry
  @@d = debug.("")
  @@timer = -> msg, fn, a {
    start_time = Time.now 
    res = fn.(a)
    "Time duration for #{msg} =  #{Time.now - start_time}" >>+ red >>+ print
    res
  }.curry
  @@delta = -> fn,  a {
    begin
      lhs = Tempfile.new('lhs')
      lhs << a.pretty_inspect
      lhs.close
      res = fn.(a)
      rhs = Tempfile.new('lhs')
      rhs << res.pretty_inspect
      rhs.close
      system("opendiff #{lhs.path} #{rhs.path}")
      res
    ensure 
      lhs.unlink
      rhs.unlink
      res
    end
  }.curry
end
