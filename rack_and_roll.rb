require './utils'

include Utils



endpoint = -> env { raise "coucou", ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }

require 'rack'

with = -> mware, init, env { a -> { mware.new(init).call(a) } }.curry

app  = with.(Rack::Lint.new(endpoint)) >>+ with.(Rack::ShowExceptions) >>+ endpoint

Rack::Server.start(
  :app => app,  :Port => 9292
)



