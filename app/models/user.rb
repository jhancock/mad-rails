class User
	include Mongoid::Document
	include Mongoid::Timestamps

	# TODO add index on email and probably many others ;)
  	field :email, type: String
  	# password_hash and password_salt are old hash method.
  	field :password_hash, type: String
  	field :password_salt, type: String
  	# TODO add field and upgrade method for getting password hashes in bcrypt
  	#field :password_bcrypt, type: String

  	field :password_reset_at, type: Time
  	field :password_reset_code, type: String  	

  	field :registered, type: Time
	field :premium, type: Time
	field :admin, type: Time

	field :geo, type: Array
	field :cn, type: String  # country code from the geo array

	# only used twice in old system for testing
	field :referral_code, type: String
	# only used once on jhancock@shellshadow.com account
	field :referred_by, type: String

	# intended for arbitrary error info for debugging purposes 
	# and to ensure we don't try to send to bad addresses more than once
	field :email_error, type: String
end
