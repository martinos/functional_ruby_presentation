require 'net/http'
require 'superators19'

class Object 
  superator ">>+" do |operand|
    operand.(self)
  end
end

class Fixnum 
  superator ">>+" do |operand|
    operand.(self)
  end
end

class Proc
  superator ">>~" do |apply_to|
    -> a {apply_to.(self.(a))}
  end
end

to_s = -> a { a.to_s }

log = (-> display, to_inspect { display.("#{to_inspect}") ; to_inspect}).curry

red = -> a { "\033[31m#{a}\033[0m"}
require 'logger'
$stdout.sync = true
logger = Logger.new($stdout)
my_log = log.(red >>~ logger.method(:puts))

kilo = -> a { a * 1000 }
mega = kilo >>~ my_log >>~ kilo

12 >>+ kilo # => 12000

mega.(2) # => "2000000"

timer = (-> info, a, b {start_time = Time.now; res = a.(b); "#{info} #{Time.now - start_time}sec" >>+ my_log; res}).curry

long_running = -> a { sleep(1.3) ; a}


"coucuo" >>+ (long_running >>+ timer.("Long Running: ")  >>~ log) # => #<Proc:0x007f86980f5458 (lambda)>


get_example = -> a {Net::HTTP.get('example.com', '/index.html') }

"coucou" >>+ (get_example >>+ timer.("http get example.com") >>~ my_log)

# >> [31mLOGIN 2000[0m
# >> [31mLOGIN 1.304699[0m
#
request = {headers: {}, method: "GET", host: "google.com", body: "" }

# extract_session >>~ authenticate 
#                 >>~ match user_path (controller >>= view_user)
#                 >>~ match _url view_user 
#

require 'rack'

app = -> env { ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }
raise_app = -> env { raise "calisse" }
handle_except = -> f { -> env { 
  begin 
    f.(env) 
  rescue RuntimeError => e
    [500, {"Content-Type" => "text/plain"}, [e.backtrace.join("\n")]]
  end
}}


Rack::Handler::WEBrick.run ((my_log >>~ handle_except.(raise_app)) >>+ timer.("duration: "))


# env = {"GATEWAY_INTERFACE"=>"CGI/1.1", "PATH_INFO"=>"/favicon.ico", "QUERY_STRING"=>"", "REMOTE_ADDR"=>"127.0.0.1", "REMOTE_HOST"=>"localhost", "REQUEST_METHOD"=>"GET", "REQUEST_URI"=>"http://localhost:8080/favicon.ico", "SCRIPT_NAME"=>"", "SERVER_NAME"=>"localhost", "SERVER_PORT"=>"8080", "SERVER_PROTOCOL"=>"HTTP/1.1", "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/2.1.3/2014-09-19)", "HTTP_HOST"=>"localhost:8080", "HTTP_CONNECTION"=>"keep-alive", "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36", "HTTP_ACCEPT"=>"image/webp,image/*,*/*;q=0.8", "HTTP_REFERER"=>"http://localhost:8080/", "HTTP_ACCEPT_ENCODING"=>"gzip, deflate, sdch, br", "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.8,fr;q=0.6", "rack.version"=>[1, 3], "rack.input"=>#<StringIO:0x007fc132147490>, "rack.errors"=>#<IO:<STDERR>>, "rack.multithread"=>true, "rack.multiprocess"=>false, "rack.run_once"=>false, , "HTTP_VERSION"=>"HTTP/1.1", "REQUEST_PATH"=>"/favicon.ico"}
