# ARGV[0] - email address of user to show

puts "Rails ENV=#{Rails.env}"
email = ARGV[0]

# pretty print a Mongoid document
def puts_doc_pp(document)
  document.attributes.each do | key, value |
    puts "#{key} -> #{value}"
  end
end

user = User.find_by(email: email)
if user
  puts "User: #{user.email}  id: #{user.id}"
  puts "email_was: #{user.email_was}" if user.email_was
  puts "==============================================="
  puts_doc_pp(user)
else
  puts "no user for email: #{email}"
end
