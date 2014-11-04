
def grant_admin email
  user = User.find_by(email: email)
  unless user then puts "#{email} not found"; return end
  if user.admin? then puts "#{user.email} already admin"; return end
  user.grant_admin
  puts "#{user.email} admin GRANTED"
end

email = "jhancock@shellshadow.com"
grant_admin email
