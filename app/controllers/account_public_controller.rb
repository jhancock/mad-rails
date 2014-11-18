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
    if User.find_by(email: params[:user][:email])
      flash.now[:form_error] = "<strong>#{params[:user][:email]}</strong> 已经被注册。如果忘记密码，请 #{view_context.link_to('重设密码', password_reset_request_path)}".html_safe
      render 'register' and return
    end
    user = User.new({:email => params[:user][:email], :registered_at => Time.now})
    user.password(params[:user][:password])
    user.create_public_id
    # save user so it gets an id
    user.save
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

  def password_reset_request
    @page_title = "重设密码"
  end

  def password_reset
    @page_title = "密码重设"
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
