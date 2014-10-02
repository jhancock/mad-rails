class EventLog
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps::Created

  store_in collection: "event_log"
  
  field :event, type: String

  def self.log(event, hash = {})
    # hash are the event attributes to be stored.
    # example: EventLog.log :email, method: "welcome", user_id: "12345"
    self.create({:event => event.to_s}.merge(hash))
  end
  
  #def insert(options={})
  #  self[:created_at] = Time.now
  #  super
  #end
  
end
