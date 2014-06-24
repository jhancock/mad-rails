class EventLog
	include Mongoid::Document
  include Mongoid::Timestamps::Created

	store_in collection: "event_log"
  
  def self.log(hash = {})
    self.create(hash)
  end
  
  #def insert(options={})
  #  self[:created_at] = Time.now
  #  super
  #end
  
end
