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
         :subject => "欢迎光临迷蝴蝶文学社区！",
         :unsub_link => unsub_url)
  end

  def registered_email_verify(user_id)
    @user = User.find(user_id)
    mail(:to => @user.email,
         :subject => "verify your email",
         :unsub_link => unsub_url)
  end

  def registered_referral(user_id)
    @user = User.find(user_id)
    mail(:to => @user.email,
         :subject => "you received one month free referral bonus",
         :unsub_link => unsub_url)
  end

  private
  def unsub_url
    "http://dev.mihudie.com/unsub/12345"
  end

end
