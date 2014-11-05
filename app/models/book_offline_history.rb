class BookOfflineHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: "books_offline_history"
 
  field :book_id, type: BSON::ObjectId
  # state should be "off" or "on"
  field :state, type: String
  field :notes, type: String

  index({book_id: 1}, {unique: false})
  index({state: 1}, {unique: false})

  def self.history?(book_id)
    self.find_by({:book_id => id}).count > 0 ? true : false
  end
  
end
