class BookOfflineHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: "books_offline_history"
 
  #TODO all old history from v1.0 are test data.  ok to delete and start off empty
  field :book_id, type: String
  field :offline_at, type: Time
  field :offline_reason, type: String
  field :online_at, type: Time
  field :online_reason, type: String

  #def self.collection_name; 'books_offline_history'; end

  #TODO offline history model not tested
  def self.history?(id)
    self.find({:book_id => id.to_s}).count > 0 ? true : false
  end
  
  def self.for_book_id(id)
    self.find({:book_id => id.to_s}).to_a
  end
end
