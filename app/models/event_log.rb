class EventLog
	include Mongoid::Document
	#TODO only want :created_at
	include Mongoid::Timestamps

	store_in collection: "event_log"
  
  def self.log(hash = {})
    self.new(hash).save()
  end
  
  #def insert(options={})
  #  self[:created_at] = Time.now
  #  super
  #end
  
end
