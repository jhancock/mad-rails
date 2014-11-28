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
    new_password = params[:user][:new_password]
    unless new_password == params[:user][:new_password_confirm]
      flash.now[:form_error] = "新密码两次输入不符"
      render "change_password" and return
    end
    unless new_password.length > 3
      flash.now[:form_error] = "密码设置不能少于4位数字或字母"
      render 'change_password' and return
    end
    current_user.password(new_password)
    current_user.save
    UserEvents.log(current_user.id, :password_changed)
    redirect_to account_home_path, :notice => "密码修改成功"
  end

  def change_email
    @page_title = "更换注册邮箱"
  end

  def change_email_post
    @page_title = "更换注册邮箱"
    new_email = params[:user][:new_email].downcase
    # verify password
    unless current_user.password?(params[:user][:password])
      flash.now[:form_error] = "密码错误"
      render 'change_email' and return
    end
    # verify email format
    unless email_valid?(new_email)
      flash.now[:form_error] = "邮箱地址格式错误"
      render 'change_email' and return
    end
    # verify new_email matches new_email_confirm
    unless new_email == params[:user][:new_email_confirm].downcase
      flash.now[:form_error] = "两次输入的邮箱地址不相符"
      render 'change_email' and return
    end
    # verify new_email not assigned to another account
    other_user = User.find_by(email: new_email)
    if other_user
      flash.now[:form_error] = "<strong>#{new_email}</strong> 此邮箱地址已经被注册".html_safe
      render 'change_email' and return
    end

    current_user.email_was = current_user.email
    current_user.email = new_email
    current_user.create_email_verify_code
    current_user.save
    send_user_mail(current_user.id, :email_verify)
    redirect_to account_home_path, notice: "您的注册邮箱已经成功修改为 #{new_email}。 我们已经向您新的注册邮箱发送了验证邮件。 请查收邮件并完成邮箱验证。".html_safe
  end

  def email_verify_notice
    @page_title = "请验证注册邮箱"
  end

  def email_verify
    email_verify_code = params[:code]
    user = User.find_by(email_verify_code: email_verify_code) if email_verify_code
    unless user && (user.id == current_user.id)
      flash[:error] = "您已经完成验证，此验证码已经无效。"
      redirect_to account_home_path and return
    end
    user.email_verified!
    reward_events = UserEvents.find_by(user_id: user.id, event: "registered_premium_bonus")
    unless reward_events
      user.extend_premium!(1.month)
      UserEvents.log(user.id, :registered_premium_bonus, {amount: "1 month"})
    end
    # user.save

    # TODO ensure registered_event only return 1 event or nil
    registered_event = UserEvents.find_by(user_id: user.id, event: "registered")
    referrer_id = registered_event[:referrer] if registered_event
    if referrer_id
      referrer = User.find(referrer_id)
      if referrer
        UserEvents.log(referrer.id, :registered_referral, {referred: user.id})
        reward_events = UserEvents.find_by(id: referrer.id, event: "registered_referral_premium_bonus")
        unless reward_events
          referrer.extend_premium!(1.month)
          #referrer.save
          UserEvents.log(referrer.id, :registered_referral_premium_bonus, {referred: user.id, amount: "1 month"})
          send_user_mail(referrer.id, :registered_referral)
        end
      end
    end
    redirect_to root_path, :notice => "恭喜！您获得了迷蝴蝶后花园免费畅读直至 #{user.premium_date_pp}"
  end
        
  private
  def ensure_user
    raise Unauthenticated.new(message: "您必需登录后才能查看账户信息。", success_path: request.original_fullpath) unless current_user
  end

end
