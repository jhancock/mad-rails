# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default from: "support@mihudie.com"
  helper MailerHelper

  # mailer method names need to be 50 characters or less.  This name gets used for Mandrill's tag info.  50 chars is the limit.  Mandrill also only allows up to 100 tag names.  So need to keep total number of mailer methods to 100
  # welcome email
  def registered(user_id)
    @user = User.find(user_id)
    #TODO figure out mandrill unsub link
    mail(:to => @user.email,
         :subject => "欢迎光临迷蝴蝶")
  end

  def email_verify(user_id)
    @user = User.find(user_id)
    mail(:to => @user.email,
         :subject => "请验证注册邮箱")
  end

  def password_reset(user_id) 
    @user = User.find(user_id)
    mail(:to => @user.email,
         :subject => "密码重设")
  end

  def registered_referral(user_id)
    @user = User.find(user_id)
    mail(:to => @user.email,
         :subject => "Referal bonus")
  end

  private
  def unsub_url
    "http://dev.mihudie.com/unsub/12345"
  end

end
