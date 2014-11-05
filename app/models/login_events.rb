class LoginEvents
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  store_in collection: "login_events"
  
  field :user_id, type: BSON::ObjectId
  field :ip, type: String
  field :event, type: String
  field :data, type: String

  index({user_id: 1}, {unique: false})
  index({ip: 1}, {unique: false})
  index({event: 1}, {unique: false})

  def self.log_success(user_id, ip)
    self.create({:user_id => user_id, :ip => ip, :event => "success"})
  end

  def self.log_bad_password(user_id, ip)
    self.create({:user_id => user_id, :ip => ip, :event => "bad_password"})
  end

  def self.log_invalid_user(email, ip)
    self.create({:ip => ip, :event => "invalid_user", :data => email})
  end

end
