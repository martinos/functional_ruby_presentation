require 'pp'
require 'http_fp'
require 'http_fp/net_http'
require 'http_fp/curl'
require 'http_fp/rack'
require './pres_utils'
require './remote_helpers'
require './strong'
require 'pry-nav'

include HttpFp
include PresUtils
include Strong
include RemoteHelpers

$stdout.sync = true
# url 
# https://api.github.com/users/martinos/starred
#
server = HttpFp::NetHttp.server >>+ (timer.("Request") >>~ retry_fn >>~ cache.(10).("stars.yml"))
json_server = with_host.("https://api.github.com") >>~ server >>~ json_resp

get_stars = -> account_name {
  verb.(:get) >>~ 
    with_path.("/users/#{account_name}/starred") >>~ 
    json_server >>~ 
    array_of.(hash_of.({"name" => same, "language" => same}))
} 

get_stars.("martinos") >>~ debug.("result") >>+ run
