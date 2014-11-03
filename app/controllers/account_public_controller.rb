# -*- coding: utf-8 -*-
class AccountPublicController < ApplicationController
  force_ssl except: :login_help
  before_action :ensure_no_user, except: :login_help

  def login
    @page_title = "Login"
    @page_description = "登录迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "登录 电子书 在线阅读"
  end

  def login_post
    @page_title = "Login"
    @page_description = "登录迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "登录 电子书 在线阅读"
    user = User.find_by(email: params[:user][:email])
    unless user
      LoginEvents.log_invalid_user(params[:user][:email], request.remote_ip)
      flash.now[:form_error] = "Login error"
      render 'login' and return
    end
    unless User.verify_password?(params[:user][:password], user.password_hash, user.password_salt)
      LoginEvents.log_bad_password(user.id, request.remote_ip)
      flash.now[:form_error] = "Login error"
      render 'login' and return
    end
    set_login(user)
  end

  def register
    @page_title = "Register"
    @page_description = "注册迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "注册 电子书 在线阅读"
  end

  def register_post
    @page_title = "Register"
    @page_description = "注册迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "注册 电子书 在线阅读"
    unless email_valid?(params[:user][:email])
      #TODO SystemEvents.log(:invalid_email_format, {:email => params[:email]})
      flash.now[:form_error] = "invalid_email_format"
      render 'register' and return
    end
    unless params[:user][:password] == params[:user][:password_confirm]
      flash.now[:form_error] = "passwords_do_not_match"
      render 'register' and return
    end
    if User.find_by(email: params[:user][:email])
      #TODO dont tell user they are already registered?
      flash.now[:form_error] = "email_already_registered"
      render 'register' and return
    end
    user = User.new({:email => params[:user][:email], :registered_at => Time.now})
    user.set_password_hash(params[:user][:password])
    #user.register_ip = request.remote_ip

    # TODO capture _r url param and store in session if exists.  do this in app controller before_action
    #user.set_referral_code #TODO - use hashids to create code based on user.id
    #referred_by = session.delete(:referred_by)

    # need to save user so it gets an id
    user.save

    #if referred_by
    #  referrer = User.find_by_referral_code(referred_by)
    #  if referrer
        #TODO should :registered be renamed :registration ??
    #    UserEvents.log(user.id, :registered, {referred_by: referrer.id})
    #    UserEvents.log(referrer.id, :referral, {registered: user.id})
    #    # give referrer their bonus and send email
    #  end
    #else
    #    UserEvents.log(user.id, :registered)        
    #end    

    UserEvents.log(user.id, :registered)
    send_user_mail(user.id, :welcome)
    set_login(user)
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
    # we remove any referral cookies when a user successfully logs in.  May solve the internet cafe problem
    # pop_captured_referral
    flash[:notice] = session.delete(:auth_success_message) if session[:auth_success_message]
    redirect_to(session.delete(:auth_success_path) || root_path)
  end

  def ensure_no_user
    if current_user
      flash[:notice] = "already logged in. back to root"
      redirect_to root_path
    end
  end
end
