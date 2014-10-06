class LoginLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  store_in collection: "login_log"
  
  field :user_id, type: BSON::ObjectId
  field :ip, type: String

  index user_id: 1

  def self.log(user_id, ip)
    self.create({:user_id => user_id, :ip => ip})
  end
    
end
