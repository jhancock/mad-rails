class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :email_verified_at, type: Time
  # one-time use code created by hashid lib based on Time.now
  field :email_verify_code, type: String
  # prior value of email field.  Useful fo rknowing what a user's email was befor ethey changed it.
  field :registered_at, type: Time
  field :email_was, type: String

  # :public_id used for referral codes, payment identifier, etc.
  field :public_id, type: String

  field :password_hash, type: String
  field :password_salt, type: String

  field :password_bcrypt, type: String

  field :password_reset_code, type: String
  field :password_reset_at, type: Time

  #TODO last bounce time. gets unset when email_verified_at gets set
  field :email_bounced_at, type: Time

  # if premium_at is set, the user has premium access.  No need to check premium_to.
  field :premium_at, type: Time
  # if premium_to is set, user has premium access to that time.
  field :premium_to, type: Time

  # an array such as ["admin", "curator", "root"] 
  field :privileges, type: Array

  field :cn, type: String  # country name (two char code) from the geo array
  field :city, type: String
  field :ip, type: String

  #TODO duplicate docs with same email.  fix and change index after migration.
  index({email: 1}, {unique: false})
  #index({email: 1}, {unique: true})
  index({public_id: 1}, {unique: true, sparse: true})
  index({email_verify_code: 1}, {unique: true, sparse: true})
  index({cn: 1}, {unique: false})
  #TODO why do I have an index on ip?.  Is it so I can ref a new user against existing users to see if a user is using a second email account to get fake referral?
  index({ip: 1}, {unique: false})
  index({privileges: 1}, {unique: false})
  index({premium_at: 1}, {unique: false})
  index({premium_to: 1}, {unique: false})

  def self.register!(email, password)
    return nil if self.find_by(email: email)
    user = self.new({:email => email, :registered_at => Time.now})
    user.password(password)
    user.create_public_id
    user.create_email_verify_code
    user.save
    user
  end

  def create_public_id
    hashids = Hashids.new(self.class.hashids_salt)
    self.public_id = hashids.encode_hex(self.id.to_s)
  end

  #TODO using unset could be a problem.  create_email_verify_code, set_email_verified, set_password_reset all doing an atomic unset and also expect the caller to save the document as well.
  def create_email_verify_code
    self.email_verify_code = self.create_use_once_id
    self.unset(:email_verified_at)
  end

  def email_verified_success
    self.unset(:email_verify_code)
    self.email_verified_at = Time.now
  end

  def create_password_reset_code
    self.password_reset_code = self.create_use_once_id
    self.password_reset_at = Time.now
  end

  # called after password has been reset.  clear the reset code and time
  def password_reset_success
    self.unset(:password_reset_code)
    self.unset(:password_reset_at)
  end

  #TODO this could return a non-unique value if Time.now is same
  def create_use_once_id
    hashids = Hashids.new(self.class.hashids_salt)
    hashids.encode(Time.now.to_i)
  end

  def email_verified?
    self.email_verified_at != nil
  end

  def premium?
    bool = self.premium_at || (self.premium_to && self.premium_to > Time.now) || self.admin?
    bool == true
  end

  # duration is a Fixnum such as 1.month
  def extend_premium(duration)
    self.premium_to = Time.now unless self.premium_to
    self.premium_to = self.premium_to + duration
  end

  def premium_date_pp
    if self.premium_at
      "no end date"
    elsif self.premium_to
      premium_to.to_s(:yyyy_mm_dd)
    else
      ""
    end
  end

  def admin?
    self.privilege?("admin")
  end

  def privilege?(privilege)
    self.privileges && (self.privileges.include?(privilege) || self.privileges.include?("root"))
  end

  def grant_admin
    self.add_to_set(privileges: "admin")
  end

  def revoke_admin
    self.pull(privileges: "admin")
  end

  # returns true if the password is correct
  def password?(password)
    if self.password_bcrypt
      BCrypt::Password.new(self.password_bcrypt) == password
    else
      password_correct = self.password_hash == OpenSSL::Digest::SHA1.hexdigest("#{self.password_salt}#{password}")
      if password_correct
        self.password(password)
        self.set(password_bcrypt: self.password_bcrypt)
      end
      password_correct
    end
  end

  def password(password)
    self.password_bcrypt = BCrypt::Password.create(password)
    self.unset(:password_hash) if self.password_hash
    self.unset(:password_salt) if self.password_salt
    # old method
    #self.password_salt = create_password_salt
    #self.password_hash = OpenSSL::Digest::SHA1.hexdigest("#{self.password_salt}#{password}")
  end

  def set_geo(ip)
    self.ip = ip
    info = GeoIP.new(Rails.configuration.mihudie.geolitecity_path).city(ip)
    if info
      self.cn = info.country_code2 if info.country_code2
      self.city = info.city_name if info.city_name 
    end
  end

  def bookmarks
    @bookmarks ||= Bookmark.where(user_id: self.id)
  end

  def self.set_public_id_all
    self.where(public_id: nil).each do |user|
      user.create_public_id
      user.save
    end
  end

  private
  def create_password_salt
    hashids = Hashids.new(self.class.hashids_salt)
    hashids.encode(Time.now.to_i)
  end

  def self.hashids_salt
    # if this changes, no prior generated hashids can be decoded
    '23885ea6ee5c8d01bfa4a04c9b34f36878fc2e647685dfcaff47ba24337b663ac46a3e4da0a2e00fab69462bc5cb5e7e1263639868cb432a7d0196b1a68d11c3'
  end
  
end
