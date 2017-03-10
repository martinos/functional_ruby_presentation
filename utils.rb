require 'active_support'
require 'json'
require 'pp'
require './operators'

$stdout.sync = true

module Utils
  mattr_accessor :parse_json, :debug, :get, :retry_fn, 
    :record, :player, :count_by, :cache, :red, :time, 
    :expired, :apply, :and_then, :default, :map, :get, :try

  @@parse_json = JSON.method(:parse)
  @@debug = -> print, a, b { print.(a) ; print.(b.to_s); b }.curry
  @@get = -> key, hash { hash[key] }.curry
  @@red = -> a { "\033[31m#{a}\033[0m" }
  # ( a -> b ) -> a -> b
  @@try = -> f, a { a.nil? ?  nil : f.(a) }.curry
  @@retry_fn = -> fn, a {
    begin
      fn.(a)
    rescue
      sleep(1)
      puts "RETRYING"
      @@retry_fn.(fn).(a)
    end
  }.curry
  @@record = -> filename, result {
    File.open(filename, "w+") { |a| a << result }
    result
  }.curry
  @@play = -> filename, _params { File.read(filename) }.curry
  # (Float -> String -> Bool) -> String -> (a -> b) -> b
  @@cache  = -> expired, filename, fn, param {
    if expired.(filename) 
      @@record.(filename).(fn.(param))
    else
      puts "reading from cache"
      @@play.(filename).(nil)
    end
  }.curry
  @@expired = -> sec, a { ! File.exist?(a)  || (Time.now - File.mtime(a)) > sec  }.curry
  @@count_by = -> fn, a { 
    a.inject({}) do |res, a| 
      by = fn.(a)
      res[by] ||= 0
      res[by] += 1
      res
    end
  }.curry
  
  # (String -> String) -> String -> ( a -> b ) -> a -> b
  @@time = -> print, msg, fn, a {
    start_time = Time.now 
    res = fn.(a)
    print.("Time duration for #{msg} =  #{Time.now - start_time}")
    res}.curry
  @@apply = -> method, a { a.send(method) }.curry
  @@default = -> default, a { a.nil? ? default : a }.curry
  @@and_then = -> f , a { a.nil? ? nil : f.(a) }.curry
  @@map = -> f, enum { enum.map(&f) }.curry
  @@get = -> key, hash { hash[key] }.curry
end


