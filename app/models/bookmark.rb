class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps
  # There are 0..n bookmarks per user.  1 per book:user pair
  #TODO delete bookmarks when delete a user?

  field :user_id, type: BSON::ObjectId
  field :book_id, type: BSON::ObjectId
  field :chunk, type: Integer

  index({user_id: 1}, {unique: false})
  index({user_id: 1, updated_at: -1}, {unique: false})
  index({book_id: 1}, {unique: false})
  index({ user_id: 1, book_id: 1 }, { unique: false })
  index({ user_id: 1, book_id: 1, updated_at: -1 }, { unique: false })
  #index({ user_id: 1, book_id: 1 }, { unique: true })
  #index({ user_id: 1, book_id: 1, updated_at: -1 }, { unique: true })

  def book
    @book ||= Book.find(self.book_id)
  end

  def self.set(user, book, chunk)
    bookmark = self.find_by({user_id: user.id, book_id: book.id})
    if bookmark
      bookmark.chunk = chunk
      bookmark.save
    else
      self.create({user_id: user.id, book_id: book.id, chunk: chunk})
    end
  end
  
end
