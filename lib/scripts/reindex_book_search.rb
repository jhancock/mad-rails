# Delete everything
puts "Deleting book index..."
Book.__elasticsearch__.client.indices.delete index: Book.index_name rescue nil
sleep 5
# will delete and recreate index?
puts "Creating book index..."
Book.__elasticsearch__.create_index! force: true
sleep 5
puts "Importing all books..."
Book.import
puts "Done!"
