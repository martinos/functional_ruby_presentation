title: Functional Ruby
theme: martinos/reveal-cleaver-theme 
output: slideshow.html

--
# Functional Ruby
--
# In Ruby 
--
# Everything Is
--
# An Object
--
# Methods, Procs, Lambdas ...
-- 
# Are
--
# Objects
--
# In Pure FP languages (Haskell, Elm...)
--
# Everything Is 
--
# A Function 
--
# Numbers, Strings, Structures...
--
# Are
--
# Functions
--
# Let's Expore The FP
--
![](images/Back_side_of_the_Moon_AS16-3021.jpg)
--
# Of Ruby
--
# Basics
--
In Ruby has great support of anonymous functions. We see them everywhere in the form of blocks.

### Blocks

```ruby
["apple", "orange", "banana"].map { |a| a.upcase }
# => ["APPLE", "ORANGE", "BANANA"]
```
---
### Procs

```ruby
upcase = Proc.new { |a| a.upcase } #=> #<Proc:0x007fcc621aa078> 

upcase.call("apple") #=> "APPLE"
upcase.("apple") #=> "APPLE"
upcase["apple"] #=> "APPLE"

["apple", "orange", "banana"].map(&upcase)
# => ["APPLE", "ORANGE", "BANANA"]
```
---

### Lambdas

```ruby
upcase = -> (a) { a.upcase } #=> #<Proc:0x008.. (lambda)>

upcase.call("apple") #=> "APPLE"
upcase.("apple") #=> "APPLE"
upcase["apple"] #=> "APPLE"

["apple", "orange", "banana"].map(&upcase)
# => ["APPLE", "ORANGE", "BANANA"]
```
---

### Scope

You can access outer scope variables from lambdas or procs

```ruby
interjection = "HEY "
shout_at = -> (name) { interjection +  name.upcase + "!" }
shout_at.("martin") #=> "HEY MARTIN"
```
---

# Partial application

Partial application refers to the process of fixing a number of arguments to a function, producing another function of smaller arity.

---

### Example with Arity 2 

```ruby
add = -> a { -> b { a + b } }
add2 =  add.(2) # => -> b { 2 + b }
add2.(3)  # => 5
```
---

### Example of Arity 3

```ruby
multi_add = -> a { -> b { -> c { a + b + c } } }
add_10 = multi_add.(10) # => -> b { -> c { 10 + b + c } }
add_10_and_1 = add_10.(1) # => -> c { 10 + 1 + c } 
add_10_and_1.(5) # => 16

add.(10).(1).(5) # => 16
```
---

Defining your lambda this way can be teadious. Ruby offers a solution for that.

Anyone ?

----

### Proc#curry 

```
add =  -> (a, b) { a + b }.curry
add2 =  add.(2)
add2.(3) # => 5
```

---

# Why Would I Use This ???

---
### Initializing Functions

Example

_y = m * x + b_

---

### Imperative Way

```ruby
class MyMath
  def self.linear(m, x, b)
    m * x + b
  end
end
```
---
### Fahrenheit Degrees From Celcius

```ruby
class INeedAClassNameForThis
  def self.fahrenheit(celcius)
    MyMath.linear(1.8, celcius, 32) 
  end
end

INeedAClassNameForThis.fahrenheit(10)
```
--
### OO Way

```ruby
class Linear
  def initialize(m, b)
    @m = m
    @b = b
  end

  def call(x)
    @m * x + @b
  end
end

to_fahrenheit = Linear.new(1.8, 32) 
to_fahrenheit.call(10)
```
---

### Functional Way

```ruby
linear = -> m, b, x { m * x + b }.curry

to_fahrenheit = linear.(1.8).(32)
to_fahrenheit.(10) # => 50.0

to_celcius = linear.(0.5555).(-7.777)
to_celcius.(50) #=> 10.0
```
---

### Partial Application For Managing Dependency Injection 

---

### Problem

I want to know the repos main language count for given Github account

---

### The OO Way

```ruby
class GithubRepoLanguageCounter
  def initialize(logger, github_client)
    @logger = logger
    @client = github_client
  end

  def call(user_name)
    repos = @client.repos(user_name)
    @logger.info("REPOS = \n #{repos}")
    repos.group_by { |a| a["language"] }
         .map { |key, val| [key, val.count] }
         .to_h
  end
end
```
---

```ruby
class GithubClient
  def repos(user_name)
    json = open("https://api.github.com/users/#{user_name}/repos?per_page=100").read
    JSON.parse(json)
  end
end

logger = Logger.new($stdout)
client = GithubClient.new
counter = RepoLanguageCounter.new(logger, client)

puts counter.call("martinos")
```
---

### The Functional Way

```ruby
language_count = -> print, fetch_repo, user_name {
  repos = fetch_repo.(user_name)
  print.("REPOS = \n  #{repos}")
  repos.group_by { |a| a["language"] }
       .map { |key, val| [key, val.count] }
       .to_h
}.curry
```
---
```ruby
fetch_repo = -> user_name { 
  json = open("https://api.github.com/users/#{user_name}/repos?per_page=100").read 
  JSON.parse(json)
}

printer = $stdout.method(:puts)
get_names = language_count.(printer).(fetch_repo)

# Somewhere else in the code
get_names.("martinosis")
```
---
```ruby
printer = -> a { a }
# or
printer = -> a { logger.info(a) }
```
---
# Function Composition
---
### The Math

```
f : a -> b
g : b -> c
h : c -> d

u(x) = g(f(x))
u = g * f

v(x) = h(u(x))
v(x) = h(g(f(x)))
v = h * (g * f)

w(x) = h(g(x))
w = h * g

v(x) = w(f(x))
v(x) = (h * g) * h
```
---
## Function Composition Is Associative
---

### Creating Composition Function

```ruby
class Proc
  def after(fn)
    -> a { self.(fn.(a)) }
  end
end
```

---

### Example

```ruby
# String -> String
lower = -> a { a.downcase }

# Pattern -> String -> String
delete = -> pattern, str { str.gsub(pattern, "") }.curry

# String -> String
remove_a = delete.("a").after(lower)
remove_a.("NOA") # => "no"
```

---

### The >>~ operator

In Elm and F# there is the `>>` operator, which combines functions in the reverse order.

```ruby
require 'superators19'

class Object
  superator ">>~" do |fn|
    fn.(self)
  end
end
```
---
### Function Composition decouples code

```
def upcase(string)
  string.upcase
end

def reverse(string)
  string.reverse
end

def upcase_and_reverse(string)
  a = upcase(string)
  reverse(a)
end
```
---

### Example

```ruby
# String -> String
remove_a = lower >>~ delete.("a")
```

Is equivalent to

```ruby
# String -> String
remove_a = delete.("a").after(lower)
```

---

### Example (The OO Way) 

```ruby
users = User.all
zip_codes = users.map { |a| a.id }
                 .map { |user_id| Address.find_by(id: user_id} }
                 .map { |addr| addr.zip_code } 
```
---
### The FP Way 

```ruby
# (a -> b) -> List a -> List b
map = -> fn, a { a.map(&:fn) }

# Model -> Symbol -> a
find_in = -> model, attr, value { model.find_by(attr => value) }

# a -> b -> c
get = -> a, method { a.send(:method) }
```

```ruby
# User -> String
zip_code_from_user = get.(:id) >>~
                     find_in.(Address).(:id) >>~
                     get.(:zip_code)
repo_names = map.(zip_code_from_user).(User.all)
```
---

# The Christmas Tree Operator (>>+)
---

# Mostly Known As The Pipe Operator (|>)

---

### Definition

```ruby
class Object
  superator ">>+" do |fn|
    fn.(self)
  end
end
```

It applies the left and side value to the last parameter of the right side.

---

### Example

```ruby
upcase = -> a { a.upcase }
reverse = -> a { a.reverse }

"this is a test" >>+ upcase >>+ reverse 
# => "TSET A SI SIHT"
```
---

### Conclusion

---

### References

#### Learning 

```
```

#### Talks

```
