db = Rails.env.production? ? "mhd_production" : "mhd_development"
scripts_dir = "/home/mhd/rails/lib/scripts/migrate_v2.0"
puts "Rails ENV=#{Rails.env}"

# drop dup_users collection
DupUser.collection.drop

# create dup_users collection
puts "Creating dup_users collection in db: #{db}"
system "mongo #{db} #{scripts_dir}/migrate_v2.0_dup_users.js"

# each document in dup_users contains field uniqueIds, an array of users collection ids.
# go through each uniqueIds array and decide which user to keep and delete the others.
puts "Deleting duplicate users"

DupUser.all.each do |doc|
  puts "start dup_user"
  puts "...uniqueIds: #{doc.uniqueIds}"
  first = doc.uniqueIds[0]
  doc.uniqueIds.each do |user_id|
    puts "......first user is #{first}"
    if first != user_id
      puts "......deleting #{user_id}"
      User.find(user_id).delete
    end
  end
end

# drop dup_users collection
DupUser.collection.drop

puts "DONE"
