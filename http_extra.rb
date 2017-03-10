require './utils'
require 'net/http'

module HttpExtra
  mattr_accessor :verb, :with_host, :with_path, :with_query, :withUri, :with_json, :withHeaders, :add_headers, :method_str_to_req, :_send, :fetch, :to_curl, :out_curl

  @@verb = -> verb, req { req[:method] = verb.upcase; req }.curry
  @@with_host = -> host_uri, req { req[:uri] = URI(host_uri); req }.curry
  @@with_path = -> path, req { req[:uri].path = path; req }.curry
  @@with_query = -> params, req {req[:uri].query = URI.encode_www_form(params) ; req }.curry
  @@withUri = -> uri, req { req[:uri] = URI(uri); req }.curry
  @@with_json = -> hash, req { req[:body] = hash.to_json; req }.curry
  @@withHeaders = -> headers, req { req[:headers] = headers ; req }.curry
  @@add_headers = -> headers, req { req[:headers] ||= {}; req[:headers].merge!(headers); req }.curry

  @@method_str_to_req = {"GET" => Net::HTTP::Get, "POST" => Net::HTTP::Post, "DELETE" => Net::HTTP::Delete, "PUT" => Net::HTTP::Put}

  @@_send = -> req { 
    uri = req[:uri]
    req_ = method_str_to_req[req[:method]].new(uri)
    req_.set_body_internal(req[:body]) if req[:body]
    headers = req[:headers]
    headers.each { |key, val| req_[key] = val}
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = uri.scheme == 'https'
    # http.set_debug_output($stdout)
    http.request(req_)
  } 

  @@fetch = _send >>~ Utils.get.(:body) >>~ Utils.parse_json
  @@print = -> a { $stdout.puts a.pretty_inspect ; a }
  @@header_to_curl = -> a {
    "-H '#{a[0]}: #{a[1]}'"
  }
  @@to_curl = -> req {
    %{curl -X '#{req[:method]}' '#{req[:uri].to_s}' #{req[:headers].map(&@@header_to_curl).join(" ")}}
  }
  @@out_curl = -> req { @@print.(to_curl.(req)) ; req}
end
