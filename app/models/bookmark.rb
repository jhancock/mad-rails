class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps
  # There are 0..n bookmarks per user.  1 per book:user pair
  #TODO delete bookmarks when delete a user?

  field :user_id, type: BSON::ObjectId
  field :book_id, type: BSON::ObjectId
  field :chunk, type: Integer
  # pretty_print the bookmark
  field :pp, type: String
  # title and author are copied in the bookmark so we don't need to retriev the book to generate printing of bookmark or generating path to the book
  field :title, type: String
  field :author, type: String

  index({user_id: 1}, {unique: false})
  index({user_id: 1, updated_at: -1}, {unique: false})
  index({book_id: 1}, {unique: false})
  # v1.0 indexes
  index({ user_id: 1, book_id: 1 }, { unique: false })
  index({ user_id: 1, book_id: 1, updated_at: -1 }, { unique: false })
  # v2.0 indexes
  #index({ user_id: 1, book_id: 1 }, { unique: true })
  #index({ user_id: 1, book_id: 1, updated_at: -1 }, { unique: true })

  def book
    @book ||= Book.find(self.book_id)
  end

  def self.set(user, book, chunk)
    bookmark = self.find_by({user_id: user.id, book_id: book.id})
    if bookmark
      bookmark.chunk = chunk
      bookmark.pp = self.create_pp(book, chunk)
      bookmark.title = book.title
      bookmark.author = book.author
      bookmark.save
    else
      self.create({user_id: user.id, book_id: book.id, chunk: chunk, pp: self.create_pp(book, chunk), title: book.title, author: book.author})
    end
  end

  # used to pre-populate pp. e.g. if things get out of sync, I may iterate through all books to set_pp using self.set_pp_all
  def self.create_pp(book, chunk = 1)
    if book
      pp = "#{book.chapter_title(chunk)} #{book.title} - #{book.author}"
    else
      pp = "bookmark error"
    end
    pp
  end

  # set pp, title and author for all bookmarks
  def self.set_pp_all
    self.all.each do |bookmark|
      book = bookmark.book
      bookmark.pp = self.create_pp(book, bookmark.chunk)
      bookmark.title = book.title if book
      bookmark.author = book.author if book
      bookmark.save
    end
  end
  
end
