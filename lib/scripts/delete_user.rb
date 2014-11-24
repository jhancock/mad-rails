email = "jhancock@shellshadow.com"
#email = "jhancock@mihudie.com"
user = User.find_by(email: email)
if user
  user.delete
  puts "user #{user.email} deleted"
else
  puts "user #{email} not found"
end
