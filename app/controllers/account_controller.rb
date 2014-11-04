# -*- coding: utf-8 -*-
class AccountController < ApplicationController
  force_ssl except: :logout
  before_action :ensure_user, except: :logout

  def index
    @page_title = "账户管理"
    @page_description = "在线管理自己账户的密码和最近阅读的书签信息 "
    @page_keywords = "账户管理 书签 电子书"
  end

  def logout
    reset_session
    @_current_user = nil
    redirect_to root_path, :notice => "You are now logged out"
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
    # send email
    # redirect to account_root with message
  end

  def register_email_verify
    public_id = params[:code]
    user = User.find_by(public_id: public_id) if public_id
    unless user && (user.id == current_user.id)
      flash[:error] = "Invalid email verification code"
      render and return
    end
    if user.email_verified_at
      flash[:notice] = "Email verified!"
      redirect_to root_path and return
    end
    user.email_verified_at = Time.now
    user.extend_premium(1.month)
    user.save

    # registered event may have been logged more than once
    registered_event = UserEvents.find_by(id: user.id, event: "registered")
    referrer_id = registered_event[:referrer] if registered_event
    if referrer_id
      referrer = User.find(referrer_id)
      if referrer
        rewarded_count = UserEvents.find_by(id: referrer.id, event: "registered_referral").count
        UserEvents.log(referrer.id, :registered_referral, {referred: user.id})
        # check if referrer already has been given registered_referral reward
        unless rewarded_count > 0
          referrer.extend_premium(1.month)
          referrer.save
          send_user_mail(referrer.id, :registered_referral)
        end
      end
    end
    redirect_to root_path, :notice => "Congradulations!  You have full access to mihudie's #{Book.online_criteria.count} backyard books until #{user.premium_to.to_s(:yyyy_mm_dd)}."
  end

  def send_change_email_verify
    # send email 
    # redirect to account_root with message"
  end

  def change_email_verify
    # validate code
    # clear user codes
    # redirect to account_root with message
  end
        
  private
  def ensure_user
    raise Unauthenticated.new(message: "You must be logged in to view your account", success_path: request.original_fullpath) unless current_user
  end

end
