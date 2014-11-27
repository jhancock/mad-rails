db = Rails.env.production? ? "mhd_production" : "mhd_development"
scripts_dir = "/home/mhd/rails/lib/scripts/migrate_v2.0"
puts "Rails ENV=#{Rails.env}"

# drop dup_books collection
DupBook.collection.drop

# create dup_books collection
puts "Creating dup_books collection in db: #{db}"
system "mongo #{db} #{scripts_dir}/migrate_v2.0_dup_books.js"

# each document in dup_books contains field uniqueIds, an array of book collection ids.
# go through each uniqueIds array and decide which book to keep online and mark the others as duplicate.
puts "Marking duplicate books"

# books_ids is an array of ids that represent duplicate books.  make on master and rest mark as duplicates
def merge_books(book_ids)
  books_hash = {}
  master_book = nil
  test_book = Book.find(book_ids[0])
  # this collection of book_ids are books that should be marked as offline, not merged
  if (test_book.author == nil) || (test_book.title == nil) || (test_book.author == "") || (test_book.title == "")
    book_ids.each do |book_id|
      Book.find(book_id).set_offline_author_or_title_not_found!
    end
    return nil
  end

  # iterate over book_ids to build books_hash and mark which will be master.
  book_ids.each do |book_id|
    books_hash[book_id] = Book.find(book_id)
    master_book ||= books_hash[book_id]
    book = books_hash[book_id]
    unless book.id == master_book.id
      # which should be master
      if (book.summary && !master_book.summary) || ((book.summary && master_book.summary) && (book.created_at > master_book.created_at))
        master_book[:master] = false
        book[:master] = true
        master_book = book
      end
    end
  end
  Book.set_master(master_book)
  # iterate again.  keep it simple
  book_ids.each do |book_id|
    book = books_hash[book_id]
    unless book[:master] == true
      Book.set_duplicate(master_book, book, true)
    end
  end
end

DupBook.all.each do |doc|
  puts "start dup_book."
  puts "...uniqueIds: #{doc.uniqueIds}"
  merge_books(doc.uniqueIds) if doc.uniqueIds.size > 1
end

# drop dup_books collection
DupBook.collection.drop

puts "DONE"
