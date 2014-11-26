class DupUser
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  store_in collection: "dup_users"
  
  field :uniqueIds, type: Array

end
