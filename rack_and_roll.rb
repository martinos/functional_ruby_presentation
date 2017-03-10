require './utils'
require "stringio"
require 'pp'

include Utils

endpoint = -> env { ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }
require 'rack'

with = -> mware, init, env {  mware.new(init).call(env) }.curry

# app  = with.(Rack::Lint.new(endpoint)) >>+ with.(Rack::ShowExceptions) >>+ endpoint

lint = with.(Rack::Lint)
show_exception = with.(Rack::ShowExceptions)
logger = with.(Rack::Logger)

class Proc
  superator "<<~" do |fn|
    -> a { self.(fn.(a)) } 
  end
end

debug = -> app, env { puts "ENV"; pp env; res = app.call(env) ;pp res; res }.curry
# app = lint.(with.(show_exception).(endpoint))
# save = -> name, content  { File.open(name, "w") { |a| a << content.pretty_inspect } }.curry
# diff = -> app, env { save.("before.txt").(env); res = app.call(env) ; save.("after.txt").(res[1]); res }.curry
middle = logger <<~ lint <<~ show_exception

default_env = {"REQUEST_METHOD" => "GET", 
               "SERVER_NAME" => "DUMMY", 
               "SERVER_PORT" => "9292", 
               "QUERY_STRING" => "", 
               "rack.version" => ["2.2"], 
               "rack.input" => StringIO.new(String.new.force_encoding(Encoding::ASCII_8BIT)) ,
               "rack.errors" => StringIO.new, 
               "rack.multithread" => false,
               "rack.multiprocess" => false,
               "rack.run_once" => true,
               "rack.url_scheme" => "http",
               "PATH_INFO" => "/"}

# puts middle.(endpoint).(default_env)

Rack::Server.start(
  :app => middle.(endpoint),  :Port => 9292
)
