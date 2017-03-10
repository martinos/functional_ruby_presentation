require './utils'

include Utils
at = get
get = -> method, a { a.send(method) }.curry


default = -> default, a { a.nil? ? default : a }.curry

user = {name: "Martin", age: 23}


big_name = try.(at.(:name)) >>~ try.(get.(:upcase)) >>~ default.("N/A") >>~ try.(get.(:downcase))

puts big_name.({})
