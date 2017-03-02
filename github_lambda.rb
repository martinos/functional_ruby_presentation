require 'open-uri'
require 'json'
require 'pry-nav'
require 'pp'
require './utils'

include Utils

cache = Utils.cache.(expired.(60))
logger = Logger.new($stdout).method(:info)
slack_printer = -> a { system(%{curl -s -X POST --data-urlencode 'payload={"text": "#{a}", "channel": "#autonotifications", "username": "martinosis", "icon_emoji": ":monkey_face:"}' https://hooks.slack.com/services/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}); a }
print = -> a { logger.(a) ; slack_printer.(a); a }

time = Utils.time.(print)
debug = Utils.debug.(print)

# String -> String
fetch_repo = -> user_name { 
  open("https://api.github.com/users/#{user_name}/repos?per_page=100").read 
}

# string -> string
safe_fetch_repo = 
  fetch_repo >>+ retry_fn >>+ cache.("coucou.json") >>+ time.("fetching repo")

# String -> Has String Int
language_count =
  safe_fetch_repo >>~
  parse_json >>~ 
  count_by.(get.("language") >>~ 
            default.("N/A") >>~
            apply.(:upcase))

puts language_count.("Martinos").inspect

# >> reading from cache
# >> {"VIML"=>3, "COFFEESCRIPT"=>1, "ELIXIR"=>13, "RUBY"=>42, "SHELL"=>4, "JAVASCRIPT"=>3, "ELM"=>8, "HTML"=>6, "VIM SCRIPT"=>1, "N/A"=>5, "GO"=>2, "C"=>1, "CSS"=>1}


