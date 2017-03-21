require 'pp'
require 'active_support'

module Strong
  mattr_reader :scalar, :same_hash, :same_array, :int, :float, :hash_of, :array_of, :default, :same

  @@scalar = -> a { a.kind_of?(Array) || a.kind_of?(Hash) ? nil : a }
  @@same = -> a { a }
  @@same_hash = -> a { a.kind_of?(Hash) ? a : nil }
  @@same_array = -> a { a.kind_of?(Array) ? a : nil }
  @@int = -> a { a.to_i }
  @@float = -> a { a.to_float }
  @@hash_of = -> fields , hash { Hash[fields.map { |(key, fn)| [key, fn.(hash[key])] }] }.curry
  @@array_of = -> fn, value { value.kind_of?(Array) ?  value.map(&fn) : [] }.curry
  @@default = -> default, a { a.nil? ? default : a }.curry
end

# contact = hash_of.(email: scalar)
# comment = hash_of.(body: scalar, email: scalar, date_time: default.(Time.now))
# post = hash_of.(desc: scalar, comments: array_of.(comment))
# user = hash_of.(name: scalar, age: int, contact: contact, posts: array_of.(post))
# params_filter = hash_of.(user: user)

# params = {user: {name: "Martin",
#                  age: "32", 
#                  pwd: "want_to_hack_your_pwd",
#                  filtered: "blabla",
#                  contact: {email: "chabotm@gmail.com", tel: "514-756-0096"},
#                  posts: [{desc: "blabla", filtered: "blabla", comments: [{email: "chabotm@gmail.com", body: "Great post!", junk: ""}]}]}}

# res = params_filter.(params)
# pp res

# {:user=>{:name=>"Martin", :age=>32, :contact=>{:email=>"chabotm@gmail.com"}}}

# >> {:user=>
# >>   {:name=>"Martin",
# >>    :age=>32,
# >>    :contact=>{:email=>"chabotm@gmail.com"},
# >>    :posts=>
# >>     [{:desc=>"blabla",
# >>       :comments=>
# >>        [{:body=>"Great post!",
# >>          :email=>"chabotm@gmail.com",
# >>          :date_time=>2017-03-17 10:36:41 -0400}]}]}}
#
# params.permit(:name, {:emails => []}, :friends => [ :name, { :family => [ :name ], :hobbies => [] }])

# friend = hash_of.({name: scalar, family: array_of.(hash_of.({name: scalar})), hobbies: array_of.(scalar)})
# user = hash_of.({name: scalar, email: array_of.(scalar), friends: array_of.(friend)})
#
#
#
