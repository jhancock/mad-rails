class DupBookmark
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  store_in collection: "dup_bookmarks"
  
  field :uniqueIds, type: Array

end
