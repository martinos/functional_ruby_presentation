
class LanguageCounter
  def initialize(logger, client)
    @logger = logger
    @client = client
  end

  def call(user_name)
    repos = @client.repos(user_name)
    @logger.info("REPOS = \n #{repos}")
    repos.group_by { |a| a["language"] }.map { |key, val| [key, val.count] }.to_h
  end
end

require 'logger'
require 'json'
require 'open-uri'

class GithubClient
  def repos(user_name)
    json = open("https://api.github.com/users/#{user_name}/repos?per_page=100").read
    JSON.parse(json)
  end
end

logger = Logger.new($stdout)
client = GithubClient.new
counter = LanguageCounter.new(logger, client)

puts counter.call("martinos")
