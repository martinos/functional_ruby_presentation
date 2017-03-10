require 'open-uri'
require 'json'
require 'pp'
require './utils'

include Utils
print = -> p { puts p.pretty_inspect; p }
debug = Utils.debug.(print)
cache = Utils.cache.(expired.(0))


fetch_repo = -> user_name { 
  # open("https://api.github.com/users/#{user_name}/repos?per_page=100").read
}

fetch_gem = -> gem {
  open("https://rubygems.org/api/v1/gems/#{gem}.json").read
}

fetch = retry_fn.(cache.("coucou.json").(fetch_gem)) 
dependencies = print >>~ fetch_gem >>~ parse_json >>~ get.("dependencies") >>~ get.("runtime") >>~ map.(get.("name"))

cached = Hash.new { |hash, key| hash[key] = dependencies.(key) }.to_proc

all_dependencies = -> gem { 
  cached.(gem).flat_map {|a| all_dependencies.(a) } }
puts all_dependencies.("jekyll")


# search_gem = -> gem { open("https://rubygems.org/api/v1/search.json?query=#{gem}").read} >>~ parse_json >>~ print

# search_gem.("cucumber")

