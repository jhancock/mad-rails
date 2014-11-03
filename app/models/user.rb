class User
  #TODO can I comment this out?  geoip should be availabel since its in Gemfiles
  #require 'geoip'
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :email_verified_at, type: Time

  field :password_hash, type: String
  field :password_salt, type: String
  #TODO upgrade password hashing to bcrypt
  #field :password_bcrypt, type: String

  field :password_reset_at, type: Time
  field :password_reset_code, type: String  	

  field :registered_at, type: Time

  # time email is sent for verification
  field :registered_email_verify_at, type: Time
  field :registered_email_verify_code, type: String

  # time email change verify is sent for verification
  field :change_email_verify_at, type: Time
  field :change_email_verify_code, type: String

  # if premium is set, the user has premium access.  No need to check premium_to.
  #TODO change :premium to :premium_at
  field :premium_at, type: Time
  # if premium_to is set, user has premium access to that time.
  field :premium_to, type: Time

  # admin
  #field :admin, type: Time
  #TODO change :admin to :privileges, an array such as ["admin", "curator", "root"] 
  field :privileges, type: Array

  #TODO remove geo attribute.  cn, city and ip are all we need
  #field :geo, type: Array
  #TODO pull infor from old geo array and set cn and city when migrating db
  field :cn, type: String  # country name (two char code) from the geo array
  field :city, type: String
  field :ip, type: String

  #TODO remove old :referral_code and :referred_by from old DB
  # only used twice in old system for testing
  field :referral_code, type: String
  # only used once on jhancock@shellshadow.com account
  field :referred_by, type: BSON::ObjectId

  # intended for arbitrary error info for debugging purposes 
  # and to ensure we don't try to send to bad addresses more than once
  # TODO can I get rid of :email_error attribute?
  field :email_error, type: String

  index email: 1
  index cn: 1
  index ip: 1

  # not used
  # returns an authenticated user or nil
  #def self.authenticate(email, password)
  #  user = self.find_by(email: email)
  #  return user if user && verify_password?(password, user.password_hash, user.password_salt)
  #  nil
  #end

  def email_verified?
    self.email_verified != nil
  end

  # returns true if the password is correct
  def self.verify_password?(password, password_hash, password_salt)
    password_hash == OpenSSL::Digest::SHA1.hexdigest("#{password_salt}#{password}") 
  end

  def set_password_hash(password)
    # create a password_salt if it doesn't exist
    self.password_salt = create_password_salt
    self.password_hash = OpenSSL::Digest::SHA1.hexdigest("#{self.password_salt}#{password}")
  end

  def set_geo(ip)
    self.ip = ip
    info = GeoIP.new(Rails.root.join(Rails.configuration.mihudie.geolitecity_path)).city(ip)
    #Rails.logger.info "IP >>> #{ip}  class: #{ip.class}"
    #Rails.logger.info "GEOIP >>> #{info}  class: #{info.class}"
    if info
      self.cn = info.country_code2 if info.country_code2
      self.city = info.city_name if info.city_name 
    end
  end

  private
  def create_password_salt
    #self.class.generate_code(16)
    hashids = Hashids.new(self.class.hashids_salt)
    hashids.encode(Time.now.to_i)
  end

  def self.hashids_salt
    # if this changes, no prior generated hashids can be decoded
    '23885ea6ee5c8d01bfa4a04c9b34f36878fc2e647685dfcaff47ba24337b663ac46a3e4da0a2e00fab69462bc5cb5e7e1263639868cb432a7d0196b1a68d11c3'
  end

  def self.generate_code(length)
    # return a string of <length> digits in base 30 format according to BASE_30_ARRAY
    id = ''
    length.times do
      id << BASE_30_ARRAY[rand(30)]
    end
    return id
  end
    
  BASE_30_ARRAY = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z']  
  
end
