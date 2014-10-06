class User
  require 'geoip'
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

  # TODO remove geo attribute.  cn, city and ip are all we need
  field :geo, type: Array
  field :cn, type: String  # country name (two char code) from the geo array
  field :city, type: String
  field :register_ip, type: String
  field :login_ip, type: String

  # only used twice in old system for testing
  field :referral_code, type: String
  # only used once on jhancock@shellshadow.com account
  field :referred_by, type: String

  # intended for arbitrary error info for debugging purposes 
  # and to ensure we don't try to send to bad addresses more than once
  # TODO can I get rid of :email_error attribute?
  field :email_error, type: String

  index email: 1
  index cn: 1
  index register_ip: 1

  # returns an authenticated user or nil
  def self.authenticate(email, password)
    user = self.find_by(email: email)
    return user if user && verify_password?(password, user.password_hash, user.password_salt)
    nil
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

  def self.set_geo(user_id, ip, purpose)
    if user = self.find(user_id)
      user.set_geo(ip, purpose)
      user.save
    end
  end

  def set_geo(ip, purpose)
    if [:register, :login].include? purpose
      info = GeoIP.new(Rails.root.join(Rails.configuration.mihudie.geolitecity_path)).city(ip)
      #Rails.logger.info "IP >>> #{ip}  class: #{ip.class}"
      #Rails.logger.info "GEOIP >>> #{info}  class: #{info.class}"
      if info
        self.cn = info.country_code2 if info.country_code2
        self.city = info.city_name if info.city_name 
        if purpose == :register 
          self.register_ip = ip
          self.login_ip = ip 
        end
        if purpose == :login 
          self.login_ip = ip 
        end
      end
    end
  end

  private
  def create_password_salt
    self.class.generate_code(16)
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
