# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default from: "support@mihudie.com"

  # welcome email
  def registered(user_id)
    @user = User.find(user_id)
    #TODO figure out mandrill unsub link
    mail(:to => @user.email,
         :subject => "欢迎光临迷蝴蝶文学社区！",
         :unsub_link => "http://dev.mihudie.com/unsub/12345")
  end

end
