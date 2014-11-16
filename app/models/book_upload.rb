class BookUpload
  include Mongoid::Document
  include Mongoid::Timestamps
  #TODO not used in v2.0 yet

  field :user_id, type: BSON::ObjectId
  field :file_name, type: String
  field :title, type: String
  field :author, type: String
  field :summary, type: String

end
