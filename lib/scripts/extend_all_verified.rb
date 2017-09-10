puts "Rails ENV=#{Rails.env}"

users = User.exists(email_verified_at: true)
puts users.count
users.all.each do |user|
  user.extend_premium!(1.year)
  puts "User: #{user.email}  id: #{user.id} extended 1 YEAR"
end

