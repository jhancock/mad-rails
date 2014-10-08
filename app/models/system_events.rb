class SystemEvents
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps::Created

  store_in collection: "system_events"
  
  field :event, type: String

  index event: 1

  def self.log(event, hash = {})
    # hash are the event attributes to be stored.
    # example: SystemEvents.log :mail_server_error, {error: "message"}
    self.create({:event => event.to_s}.merge(hash))
  end

end
