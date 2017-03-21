require 'pp'
require 'http_fp'
require 'http_fp/net_http'
require 'http_fp/curl'
require './pres_utils'
require './remote_helpers'
require './strong'

include HttpFp
include PresUtils
include Strong
include RemoteHelpers

# /users/#{user_name}/repos?per_page=100

$stdout.sync = true
same = -> a { a }
print = -> a { puts a }

server = HttpFp::NetHttp.server >>+ (cache.(3600).("cache.yml") >>~ timer.("server_request") >>~ retry_fn )

host = with_host.("https://api.github.com") >>~ server >>~ resp_to_json

verb.("get") >>~ with_path.("/users/martinos/starred") >>~ 
                 with_query.(page: 1, per_page: 2) >>~ 
                 host >>~ 
                 array_of.(hash_of.("full_name" => same)) >>~ 
                 debug.("json_response") >>+ run



