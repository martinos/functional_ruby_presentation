require 'pp'
require 'http_fp'
require 'http_fp/net_http'
require './pres_utils'
require './strong'

include HttpFp
include PresUtils
include Strong

# /users/#{user_name}/repos?per_page=100

same = -> a { a }
server = HttpFp::NetHttp._send >>+ time.("server_request")

host = with_host.("https://api.github.com") >>~ server >>~ resp_to_json >>~ debug.("JSON response") 

verb.("get") >>~ with_path.("/users/martinos/repos") 

verb.("get") >>~ with_path.("/users/martinos/starred") >>~ 
                 with_query.(page: 1, per_page: 1000) >>~ 
                 host >>~ 
                 array_of.(hash_of.("full_name" => same)) >>~ 
                 debug.("json_response") >>+ run



