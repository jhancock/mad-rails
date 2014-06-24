class MailLog
	include Mongoid::Document
	include Mongoid::Timestamps::Created

	store_in collection: "mail_log"

  field :email, type: String
  field :campaign, type: String
  
  def self.log(email, campaign)
    self.create(email: email, campaign: campaign)
  end
  
  # To delete, use mongoid's API directly
  # MailLog.delete_all(email: email, campaign: campaign)  
end
