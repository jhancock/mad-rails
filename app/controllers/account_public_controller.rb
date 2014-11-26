# -*- coding: utf-8 -*-
class AccountPublicController < ApplicationController
  force_ssl except: :login_help
  before_action :ensure_no_user, except: :login_help

  def login
    @page_title = "登录"
    @page_description = "登录迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "登录 电子书 在线阅读"
  end

  def login_post
    @page_title = "登录"
    @page_description = "登录迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "登录 电子书 在线阅读"
    user = User.find_by(email: params[:user][:email])
    unless user
      LoginEvents.log_invalid_user(params[:user][:email], request.remote_ip)
      flash.now[:form_error] = "用户名或者密码错误 #{view_context.link_to('重设密码', password_reset_request_path)}".html_safe
      render 'login' and return
    end
    unless user.password?(params[:user][:password])
      LoginEvents.log_bad_password(user.id, request.remote_ip)
      flash.now[:form_error] = "用户名或者密码错误 #{view_context.link_to('重设密码', password_reset_request_path)}".html_safe
      render 'login' and return
    end
    set_login(user)
  end

  def register
    @page_title = "注册"
    @page_description = "注册迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "注册 电子书 在线阅读"
  end

  def register_post
    @page_title = "注册"
    @page_description = "注册迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "注册 电子书 在线阅读"
    unless email_valid?(params[:user][:email])
      flash.now[:form_error] = "邮箱地址格式错误"
      render 'register' and return
    end
    unless params[:user][:password] == params[:user][:password_confirm]
      flash.now[:form_error] = "两次密码填写不符"
      render 'register' and return
    end
    unless params[:user][:password].length > 3
      flash.now[:form_error] = "密码设置不能少于4位数字或字母"
      render 'register' and return
    end
    user = User.register!(params[:user][:email], params[:user][:password])
    unless user
      flash.now[:form_error] = "<strong>#{params[:user][:email]}</strong> 已经被注册。如果忘记密码，请 #{view_context.link_to('重设密码', password_reset_request_path)}".html_safe
      render 'register' and return
    end
    referrer_public_id = session[:referrer]
    referrer = User.find_by(public_id: referrer_public_id) if referrer_public_id
    if referrer
      UserEvents.log(user.id, :registered, {referrer: referrer.id})
    else
      UserEvents.log(user.id, :registered)
    end
    send_user_mail(user.id, :registered)
    set_login(user)
  end

  # password_reset methods are accessible to logged in users.
  def password_reset_request
    @page_title = "重设密码"
  end

  def password_reset_request_post
    @page_title = "重设密码"
    email = params[:user][:email]
    unless email_valid?(email)
      flash.now[:form_error] = "邮箱地址格式错误"
      render 'password_reset_request' and return
    end
    user = User.find_by(email: email)
    flash[:notice] = "如果您输入的邮箱地址为已经验证过的邮箱，我们会发送重设密码邮件到此邮箱地址"
    if user && user.email_verified?
      user.create_password_reset_code
      user.save
      send_user_mail(user.id, :password_reset)
    end
    redirect_to root_path
  end

  def password_reset
    @page_title = "密码重设"
    @bad_code = true
    @user = User.find_by(password_reset_code: params[:code])
    # if no user or if code expired set @bad_code to true and change view accordingly
    if @user && ((Time.now - @user.password_reset_at) < 1.week)
      @bad_code = false
    end
  end

  def password_reset_post
    @page_title = "密码重设"
    @bad_code = true
    new_password = params[:user][:new_password]
    unless new_password == params[:user][:new_password_confirm]
      flash.now[:form_error] = "两次密码填写不符"
      render 'password_reset' and return
    end
    unless new_password.length > 3
      flash.now[:form_error] = "密码设置不能少于4位数字或字母"
      render 'password_reset' and return
    end
    @user = User.find_by(password_reset_code: params[:code])
    # if no user or if code expired set @bad_code to true and change view accordingly
    if @user && ((Time.now - @user.password_reset_at) < 1.week)
      @bad_code = false
      @user.password(new_password)
      @user.password_reset_success
      @user.save
      flash[:notice] = "密码重设成功。 您现在已经登录。"
      set_login(@user)
    else
      render 'password_reset'
    end
  end

  def login_help
    @page_title = "登录帮助"
    @page_description = "如果登录迷蝴蝶中文电子书在线阅读网站遇到问题，可以点击帮助 页面，联系网站客服人员"
    @page_keywords = "问题 帮助 电子书 在线阅读"
  end

  private
  def set_login(user)
    remote_ip = request.remote_ip
    user.set_geo(remote_ip)
    user.save
    LoginEvents.log_success(user.id, remote_ip)
    session[:id] = user.id.to_s
    session.delete(:referrer)
    flash[:notice] = session.delete(:auth_success_message) if session[:auth_success_message]
    redirect_to(session.delete(:auth_success_path) || root_path)
  end

  def ensure_no_user
    raise Unauthorized.new(message: "此页面不适用于已经登录的用户") if current_user
  end
end
