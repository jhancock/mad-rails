class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps
  # There are 0..n bookmarks per user.  1 per book:user pair
  #TODO delete bookmarks when delete a user?  
  #TODO rewrite bookmark methos/mongodb queries

  field :user_id, type: BSON::ObjectId
  field :book_id, type: BSON::ObjectId
  field :chunk, type: Integer

  index({user_id: 1}, {unique: false})
  index({book_id: 1}, {unique: false})
  index({ user_id: 1, book_id: 1 }, { unique: false })
  index({ user_id: 1, book_id: 1, updated_at: -1 }, { unique: false })
  #index({ user_id: 1, book_id: 1 }, { unique: true, drop_dups: true })
  #index({ user_id: 1, book_id: 1, updated_at: -1 }, { unique: true, drop_dups: true })

  def book
    @book ||= Book.find(self[:book_id])
  end
  
  # return Integer or nil
  def self.get(user_id, book_id)
    bookmark = self.where({user_id: user_id, book_id: book_id}).first
    bookmark ? bookmark[:chunk] : nil
  end
  
  def self.set(user_id, book_id, chunk)
    bookmark = self.where({:user_id => user_id, :book_id => book_id}).first
    bookmark ||= self.new({:user_id => user_id, :book_id => book_id})
    bookmark.chunk = chunk
    bookmark.save
  end
  
  def self.reset(user_id, book_id)
    bookmark = self.remove({:user_id => user_id, :book_id => book_id})
  end
  
  def self.reset_all(user_id)
    bookmarks = self.remove({:user_id => user_id})
  end
  
end
