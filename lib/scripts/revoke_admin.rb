
def revoke_admin email
  user = User.find_by(email: email)
  unless user then puts "#{email} not found"; return end
  unless user.admin? then puts "#{user.email} NOT admin"; return end
  user.revoke_admin
  puts "#{user.email} admin REVOKED"
end

email = "jhancock@shellshadow.com"
revoke_admin email
