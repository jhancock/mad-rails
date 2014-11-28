# ARGV[0] - email address of user to show
# ARGV[1] - extend_premium (optional)

puts "Rails ENV=#{Rails.env}"
email = ARGV[0]
extend_premium = (ARGV[1] == "extend_premium") ? true : false

# pretty print a Mongoid document
def puts_doc_pp(document)
  document.attributes.each do | key, value |
    puts "#{key} -> #{value}"
  end
end

user = User.find_by(email: email)
if user
  user.email_verified!
  puts "User: #{user.email}  id: #{user.id}"
  puts "email_was: #{user.email_was}" if user.email_was
  puts "==============================================="
  if extend_premium && user.premium_at
    user.extend_premium!(1.year)
    puts "premium extended for 1 YEAR"
  elsif extend_premium
    puts "premium extended for 1 MONTH"
    user.extend_premium!(1.month)
  end
  puts "new attributes:"
  puts_doc_pp(User.find(user.id))
else
  puts "no user for email: #{email}"
end
