db = Rails.env.production? ? "mhd_production" : "mhd_development"
scripts_dir = "/home/mhd/rails/lib/scripts/migrate_v2.0"
puts "Rails ENV=#{Rails.env}"

# drop dup_bookmarks collection
DupBookmark.collection.drop

# create dup_bookmarks collection
puts "Creating dup_bookmarks collection in db: #{db}"
system "mongo #{db} #{scripts_dir}/migrate_v2.0_dup_bookmarks.js"

# each document in dup_bookmarks contains field uniqueIds, an array of bookmark collection ids.
# go through each uniqueIds array and decide which bookmark to keep and delete the others.
puts "Deleting duplicate bookmarks"

DupBookmark.all.each do |doc|
  puts "start dup_bookmark."
  puts "...uniqueIds: #{doc.uniqueIds}"
  first = doc.uniqueIds[0]
  doc.uniqueIds.each do |bookmark_id|
    puts "......first bookmark is #{first}"
    if first != bookmark_id
      puts "......deleting #{bookmark_id}"
      Bookmark.find(bookmark_id).delete
    end
  end
end

# drop dup_bookmarks collection
DupBookmark.collection.drop

puts "DONE"
