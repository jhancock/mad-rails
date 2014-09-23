namespace :mhd do
  desc "grant admin to hard coded user by email"
  task grant_admin: :environment do
    email = "jhancock@shellshadow.com"
    user = User.find_by(email: email)
    puts "#{email} not found" and next unless user
    puts "#{user.email} already admin #{user.admin}" and next if user.admin
    user.admin = Time.now
    user.save
    puts "#{user.email} GRANTED admin @ #{user.admin}"
  end
end
