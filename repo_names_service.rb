require 'open-uri'
require 'json'
require 'logger'

class GithubClient
  def fetch_repo(user_name)
    json = open("https://api.github.com/users/#{user_name}/repos?per_page=100").read 
    JSON.parse(json)
  end
end

class RepoNamesService
  def initialize(logger, github)
    @logger = logger
    @github = github
  end

  def language_count(user_name)
    repos = @github.fetch_repo(user_name)
    @logger.info("REPOS = \n  #{repos}")
    repos.group_by { |a| a["language"] } .map { |key, val| [key, val.count] }.to_h
  end
end

logger = Logger.new($stdout)
logger = Logger.new(File.open("/dev/null", "w"))

service = RepoNamesService.new(logger, GithubClient.new)
puts service.language_count("martinos")

