
def grant_admin email
  user = User.find_by(email: email)
  unless user then puts "#{email} not found"; return end
  if user.admin then puts "#{user.email} already admin #{user.admin}"; return end
  user.admin = Time.now
  user.save
  puts "#{user.email} admin GRANTED @ #{user.admin}"
end

email = "jhancock@shellshadow.com"
grant_admin email
