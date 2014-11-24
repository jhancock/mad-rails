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
    redirect_to root_path, :notice => "您已经退出登录状态"
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
    unless current_user.password?(params[:user][:password])
      UserEvents.log(current_user.id, :password_change_error, {error: "incorrect_current_password"})
      flash.now[:form_error] = "当前的密码错误"
      render "change_password" and return
    end
    unless params[:user][:new_password] == params[:user][:new_password_confirm]
      UserEvents.log(current_user.id, :password_change_error, {error: "new_passwords_do_not_match"})
      flash.now[:form_error] = "新密码两次输入不符"
      render "change_password" and return
    end
    current_user.password(params[:user][:new_password])
    current_user.save
    UserEvents.log(current_user.id, :password_changed)
    redirect_to account_home_path, :notice => "密码修改成功"
  end

  def change_email
    @page_title = "更换注册邮箱"
  end

  def change_email_post
    @page_title = "更换注册邮箱"
  end

  def registered_email_verify_notice
    @page_title = "请验证注册邮箱"
  end

  def registered_email_verify
    #TODO change from public_id to email_verify_code
    public_id = params[:code]
    user = User.find_by(public_id: public_id) if public_id
    unless user && (user.id == current_user.id)
      flash[:error] = "您已经完成验证，此验证码已经无效。"
      redirect_to account_home_path and return
    end
    if user.email_verified_at
      flash[:notice] = "邮箱验证完成! 恭喜您获得迷蝴蝶后花园 #{Book.online_criteria.count} 书籍免费畅读至  #{user.premium_date_pp}。"
      redirect_to root_path and return
    end
    user.email_verified_at = Time.now
    user.extend_premium(1.month)
    user.save

    # TODO ensure registered event not logged more than once.  
    registered_event = UserEvents.find_by(id: user.id, event: "registered")
    referrer_id = registered_event[:referrer] if registered_event
    if referrer_id
      referrer = User.find(referrer_id)
      if referrer
        UserEvents.log(referrer.id, :registered_referral, {referred: user.id})
        rewarded_count = UserEvents.find_by(id: referrer.id, event: "registered_referral").count
        # check if referrer already has been given registered_referral reward
        unless rewarded_count > 0
          referrer.extend_premium(1.month)
          referrer.save
          send_user_mail(referrer.id, :registered_referral)
        end
      end
    end
    redirect_to root_path, :notice => "恭喜！您获得了迷蝴蝶后花园免费畅读直至 #{user.premium_date_pp}"
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
    raise Unauthenticated.new(message: "您必需登录后才能查看账户信息。", success_path: request.original_fullpath) unless current_user
  end

end
