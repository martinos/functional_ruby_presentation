require 'active_support'

module RemoteHelpers
  mattr_reader :retry_fn, :record, :play, :cache, :time

  @@retry_fn = -> fn, a {
    begin
      fn.(a)
    rescue
      sleep(1)
      puts "RETRYING"
      @@retry_fn.(fn).(a)
    end
  }.curry
  @@record = -> filename, to_save {
    File.open(filename, "w+") { |a| a << to_save.to_yaml }
    to_save
  }.curry
  @@play = -> filename, _params { YAML.load(File.read(filename)) }.curry
  # (Number -> String -> Bool) -> String -> (a -> b) -> b
  @@is_expired = -> sec, a { ! File.exist?(a)  || (Time.now - File.mtime(a)) > sec  }.curry
  @@cache  = -> filename, duration,  fn, param {
    if @@is_expired.(duration).(filename) 
      @@record.(filename).(fn.(param))
    else
      puts "reading from cache"
      @@play.(filename).(nil)
    end
  }.curry
  
  # (String -> String) -> String -> ( a -> b ) -> a -> b
  @@time = -> print, msg, fn, a {
    start_time = Time.now 
    res = fn.(a)
    print.("Time duration for #{msg} =  #{Time.now - start_time}")
    res}.curry
end
