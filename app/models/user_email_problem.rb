class UserEmailProblem
  include Mongoid::Document

  store_in collection: "user_email_problems"
  
  field :user_id, type: BSON::ObjectId

end
