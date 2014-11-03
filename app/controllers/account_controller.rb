# -*- coding: utf-8 -*-
class AccountController < ApplicationController
  force_ssl except: :logout
  before_action :ensure_user

  def index
    @page_title = "账户管理"
    @page_description = "在线管理自己账户的密码和最近阅读的书签信息 "
    @page_keywords = "账户管理 书签 电子书"
  end

  def logout
    reset_session
    @_current_user = nil
    redirect_to root_url, :notice => "logout_success"
  end

  def change_password
    @page_title = "修改密码"
    @page_description = "修改自己的登录密码"
    @page_keywords = "密码 在线阅读"
  end

  def change_password_post
    @page_title = "修改密码"
    @page_description = "修改自己的登录密码"
    @page_keywords = "密码 在线阅读"
  end

  def change_email
    #TODO need chinese txt
    @page_title = "change email"
    @page_description = "change email"
    @page_keywords = "change email"
  end

  def change_email_post
    #TODO need chinese txt
    @page_title = "change email"
    @page_description = "change email"
    @page_keywords = "change email"
  end

  def send_register_email_verify

  end

  def register_email_verify

  end

  def send_change_email_verify
    # send email and redirect to prior page with message"
  end

  def change_email_verify

  end
        
  private
  def ensure_user
    #raise Unauthenticated.new(message: "You must be logged in to view your account", success_path: request.original_fullpath, success_message: "Thank you for loggin in.  Here's your account page ;)") unless current_user
    raise Unauthenticated.new(message: "You must be logged in to view your account", success_path: request.original_fullpath) unless current_user

  end
end
