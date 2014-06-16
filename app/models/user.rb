class User
	include Mongoid::Document
  	include Mongoid::Timestamps

  	field :email, type: String
  	field :password_hash, type: String
  	field :password_salt, type: String

  	field :password_reset_at, type: Time
  	field :password_reset_code, type: String  	

  	field :registered, type: Time
	field :premium, type: Time
	field :admin, type: Time

	field :geo, type: Array
	field :cn, type: String  # country code from the geo array

	field :referral_code, type: String
	#TODO be sure I understand how this value was suposed to be used
	field :referred_by, type: String

	field :email_error, type: String
end
