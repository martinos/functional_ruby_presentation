require './utils'
require 'open-uri'

include Utils

query = %{select * from weather.forecast where woeid in (select woeid from geo.places(1) where text="nome, ak")}

puts URI.escape(query)

puts %{https://query.yahooapis.com/v1/public/yql?q=#{URI.escape(query)}}
puts %{https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22nome%2C%20ak%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys}

try_at = -> a { try.(get.(a)) }

fetch = -> a {
  query = %{select * from weather.forecast where woeid in (select woeid from geo.places(1) where text="nome, ak")}
  open("https://query.yahooapis.com/v1/public/yql?q=#{URI.escape(query)}").read
}
print = -> a {$stdout.puts a ; a}
print.("Martin")



# debug = debug.(printer)

weather = fetch  >>~ 
          parse_json >>~ 
          debug.(print).("query") >>~
          try_at.("query") >>~ 
          try_at.("results") >>~ 
          try_at.("channel") >>~
          try_at.("item") >>~
          try_at.("forecast") >>~ 
          default.([])

pp weather.("")
  
