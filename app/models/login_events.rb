class LoginEvents
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  store_in collection: "login_events"
  
  field :user_id, type: BSON::ObjectId
  field :ip, type: String
  field :reason, type: String

  index user_id: 1
  index ip: 1
  index reason: 1

  def self.log_success(user_id, ip)
    self.create({:user_id => user_id, :ip => ip, :reason => "success"})
  end

  def self.log_bad_password(user_id, ip)
    self.create({:user_id => user_id, :ip => ip, :reason => "bad_password"})
  end

  def self.log_invalid_user(email, ip)
    self.create({:ip => ip, :reason => email})
  end

  #def self.log_no_user(user_id, ip)
  #  self.create({:user_id => user_id, :ip => ip, :reason => "no_user"})
  #end

end
