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
server = timer.("Request Time").(cache.(10).("mtlrb.yml").(retry_fn.(HttpFp::NetHttp.rack(Rails.application))))
json_server =  server >>~ json_resp

get_stars = -> acccount {
run.(
(verb.(:get) >>~ 
        with_path.("/users/#{account}/starred") >>~ 
        with_host.("https://api.github.com") >>~ 
        json_server >>~ 
        array_of.(hash_of.("name" => same, "language" => same)) >>~ d))}
