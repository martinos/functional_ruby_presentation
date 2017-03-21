title: Functional Ruby
theme: martinos/reveal-cleaver-theme
output: slideshow.html

--
# Functional Ruby
--
## In Ruby Everything Is
--
## An Object
--
## Methods, Procs, Lambdas Are
--
## Objects
--
## In Pure FP languages (Haskell, Elm...), Everything Is
--
## A Function
--
## Numbers, Strings, Structures Are
--
## Functions
--
## Let's Explore The Functional Side Ruby
--
# Basics
--
Ruby has great support for anonymous functions. We see them everywhere in the form of blocks.


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
add2 = add.(2) # => -> b { 2 + b }
add2.(3)  # => 5
add.(2).(3)  # => 5
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

Defining your curried lambda this way can be tedious. Ruby offers a solution for that.

Anyone ?

----

### Proc#curry

```ruby
add =  -> (a, b) { a + b }.curry
add2 = add.(2)
add2.(3) # => 5
```

---

## Why Would I Use This ???

---

### Initializing Functions

---

### Example 1 
#### Linear Function

---

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

### Example 2 
#### Poor's man Strong Parameters

---

```ruby
params = {name: "Joe", age: "23", pwd: "hacked_password"}
```

```ruby
filter_hash.([:name, :age]).(params)
# => {name: "Joe", age: "23"}
```

```ruby
filter_hash = -> keys, params {
  Hash[keys.map { |key| [key, param[key]] }]
}.curry
```

----

```ruby
params = {name: "Joe", age: "23", pwd: "hacked_password",
          contact: { address: "2342 St-Denis",
                     to_filter: ""}}
```

```
filter_hash.([:name, :age, :contact]).(params)

hash_of.(name: -> a {a}, 
         age: -> a {a}, 
         contact: hash_of.(address: -> a {a})).(params)
```
---

```ruby
filter_hash = -> keys, hash {
  Hash[keys.map { |key| [key, hash[key]] }]
}.curry
```

---

```ruby
hash_of = -> fields, hash { 
  Hash[fields.map { |(key, fn)| [key, fn.(hash[key])] }] 
}.curry
```
---

#### The Identity Function

```ruby
same = -> a { a }
same.(2) # => 2
```

---

```ruby
hash_of.(name: -> a {a}, 
         age: -> a {a}, 
         contact: hash_of.(address: -> a {a}))
```

---

```ruby
hash_of.(name: same, 
         age: same, 
         contact: hash_of.(address: same))
```

---

```ruby
contact = hash_of.(address: same)
user = hash_of.(name: same, age: same,
                contact: hash_of.(contact))
```

---
```ruby
array_of = -> fn, value {
  if value.kind_of?(Array)
    value.map(&fn)
  else
   []
}.curry

default = -> default, a { a.nil? ? default : a  }.curry
to_int = => a { a.to_i }
```
---
```ruby
contact = hash_of.(address: default.("N/A")) 
params = [{address: "21 Jump Street", remove: "me" }, 
          {}]
array_of.(contact).(params)
# => [{address: "21 Jump Street"}, 
#     {address: "N/A"}]
```
---


### Partial Application For Managing Dependency Injection

---

### The OO Way

```ruby
class GithubRepoLanguageCounter
  def initialize(logger, github_client)
    @logger = logger
    @client = github_client
  end

  def call(account_name)
    repos = @client.repos(account_name)
    @logger.info("REPOS = \n #{repos}")
    # Do some stuff with the repos
  end
end
```
---

```ruby
class GithubClient
  def repos(account_name)
    json = open("https://api.github.com/users/#{account_name}/repos?per_page=100").read
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
language_count = -> print, fetch_repo, account_name {
  repos = fetch_repo.(account_name)
  print.("REPOS = \n  #{repos}")
  # do some stuff with the repos
}.curry
```
---
```ruby
fetch_repo = -> account_name {
  json = open("https://api.github.com/users/#{account_name}/repos?per_page=100").read
  JSON.parse(json)
}

printer = -> a { puts a }
my_counter = language_count.(printer).(fetch_repo)

# Somewhere else in the code
my_counter.("martinosis")
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

In programming it's very frequent to do a calculation, take the result and pass it to another method or a function.

```ruby
def user_is_major(email)
  user = User.find_by(email: email)
  age = Time.now - user.birthdate
  age >= 18.years
end
```
---
```ruby
user_from_email = -> e { User.find_by(email: e) }
user_age = -> user { Time.now - user.birthdate }
is_major = -> age { age >= 18.years }

is_user_major = -> email { 
  is_major.(user_age.(user_from_email.(email)))
}.curry

is_user_major.("joebloe@acme.com")
```

---

#### Function Composition Is Associative

---

#### The >>~ operator

Also know as `>>` in F# and Elm 

```ruby
require 'superators19'

class Proc
  superator ">>~" do |fn|
    fn.(self)
  end
end
```
---

### Function Composition decouples code

```ruby
is_user_major = -> email { is_major.(user_age.(user_from_email.(email)))}

is_user_major = user_from_email >>~ user_age >>~ is_major
is_user_major.("joebloe@acme.com")
```

---
![alt text](images/composition.png "Logo Title Text 1")
---


## The Christmas Tree Operator (>>+)

---

## Mostly Known As The Pipe Operator (|>)

---

### Definition

```ruby
class Object
  superator ">>+" do |fn|
    fn.(self)
  end
end
```

---

It applies the left and side value to the last parameter of the right side.

---

### Example

```ruby
upcase = -> a { a.upcase }
reverse = -> a { a.reverse }

"this is a test" >>+ upcase >>+ reverse
# => "TSET A SI SIHT"

reverse.(upcase.("this is a test"))
```
---
### This pipe operator is not associative
---

### Conclusion

---

### References

#### Learning

```ruby
```

#### Talks

```ruby
