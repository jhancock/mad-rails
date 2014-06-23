class MailLog
	include Mongoid::Document
	#TODO only want :created_at
	include Mongoid::Timestamps

	store_in collection: "mail_log"

  field :email, type: String
  field :campaign, type: String
  
  def self.log(hash = {})
    self.new(hash).save()
  end
  
  #def insert(options={})
  #  self[:created_at] = Time.now
  #  super
  #end
  
end
