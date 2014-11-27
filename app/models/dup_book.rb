class DupBook
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  store_in collection: "dup_books"
  
  field :uniqueIds, type: Array

end
