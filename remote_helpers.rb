require 'active_support'

module RemoteHelpers
  mattr_reader :retry_fn, :record, :play, :cache, :time

  @@retry_fn = -> fn, a {
    begin
      fn.(a)
    rescue Exception => e
      puts e
      puts "RETRYING"
      sleep(1)
      @@retry_fn.(fn).(a)
    end
  }.curry
  @@record = -> filename, to_save {
    File.open(filename, "w+") { |a| a << to_save.to_yaml }
    to_save
  }.curry
  @@play = -> filename, _params { YAML.load(File.read(filename)) }.curry
  @@is_expired = -> sec, a { ! File.exist?(a)  || (Time.now - File.mtime(a)) > sec  }.curry
  @@cache  = -> duration, filename, fn, param {
    if @@is_expired.(duration).(filename) 
      puts "caching"
      @@record.(filename).(fn.(param))
    else
      puts "reading from cache"
      @@play.(filename).(nil)
    end
  }.curry
end
