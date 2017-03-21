# Simple Strong Parameters in Ruby

I am a full time Ruby programmer but I don't program Rails every day. very time that I need to use the Rails strong parameters I don't remember the API.

Here is an example taken from the README.md page.

```
params.permit(:name, {:emails => []}, :friends => [ :name, { :family => [ :name ], :hobbies => [] }])
```

There is a lot of stuff in here that hurts my brain.

The permit function parameters seems to represent an array of attributes.  There is some splatting done somewhere... Splatting makes methods harder to understand,
since it not how methods are used 99% of the time. This breaks the Principle of Least Surprise.

Ok it seems that `[]` reprensent an array.  Ok, I can see that, but it feels weird to me.


Ih the case of

    friends => [ :name, { :family => [ :name ], :hobbies => [] }])

the outher array represent an array of friends. But in this case:


:family => [ :name ]

The array represents a hash. For me this violates the Least Surprise Principle and it makes me think that the Strong parameters has branching condition to handle this case. Since I can't easily see the logic behind strong parameters it makes it hard for me to remember how the api works.


## The FP Solution

Lately I was listening to the Bike Shed podcast and they where talking about issues with strong paremeters, I was saying to myself that this api is way to magical at my taste, I was also preparing a talk at my local meetup about Functional Programming Patterns in Ruby and I got this idea to try to implement strong parameters using lambdas.

### Introduction To Currying
In order to understand this blog you need to know about function currying and lambdas.

In functional programming you can represent all functions using one parameters that returns them selves a function with on parametres.

You can represent normal 2 parementers lambda this way:

```
add = -> a , b  { a + b }
```

To call it
```
add.(2, 3) # => 5
```

You can represent this the same function using currying:

```
add = -> a { -> b  { a + b } }
```

This way, the add function takes one params and returns a function that take one params

```
add.(2)
```

Is the same as

```
-> b  { 2 + b }
```

So in order to calculate the result you must apply 2 and to the resulted function you apply the 3.

```
add.(2).(3) # => 5
```

Creating curried function manually is not practical this is where the Proc#curry shines. This function automatically curry any function of any arities.

```
add = -> a, b { a + b }.curry
add.(2).(3) # => 5
```

The interesting think about currying is that you can initialize your function and use it later.

### Poor's man  Strong Parameters

Let say we want to filter a hash an keep only the keys we are interested in. We can create a function that takes an array of keys and a hash and returns an hash with only the fields that corresponds to these keys.

```
hash_of = -> keys, hash { Hash[keys.map { |a| [a, hash[a]] }] }.curry
```

To use it
```
filter_client = hash_of.([:name, :age])
params = {name: "Martin", age: 23, password: "hacked_pwd"}
filter_client.(params) # => {:name=>"Martin", :age=>23}
```

This is good but what if we want to have nested hashes. Instead of using an array of keys we can pass an hash keys that we want to keep and an associated filter function that will filter the value.

```
hash_of = -> fields , hash { Hash[fields.map { |(key, fn)| [key, fn.(hash[key])] }] }.curry
```
In order to use it we will need to define a function that will keep the value of the field.

```
same = -> a { a }
```

```
filter_client = hash_of.({name: same, age: same})
params = {name: "Martin", age: 23, password: "hacked_pwd"}
filter_client.(params) # => {:name=>"Martin", :age=>23}
```

We can now use this new `hash\_of` to filter out sub hashes.

Lets say that we want to filter the user and his contact info. We need to create 2 filter functions.

```
filter_contact = hash_of.({email: same, tel: same})
filter_user = hash_of.({name: same, tel: same, contact: filter_contact})

```
We apply it
```
params = {name: "Martin",
          age: 32,
          password: "want_to_hack_your_pwd",
          contact: {email: "chabotm@gmail.com", tel: "514-756-0096", admin: true}}

pp filter_user.(params)

# >> {:name=>"Martin",
# >>  :tel=>nil,
# >>  :contact=>{:email=>"chabotm@gmail.com", :tel=>"514-756-0096"}}

```
