# -*- coding: utf-8 -*-
class AccountPublicController < ApplicationController
  force_ssl except: :login_help
  before_action :ensure_no_user, except: :login_help

  def login
    @page_title = "登录迷蝴蝶 电子书在线阅读"
    @page_description = "登录迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "登录 电子书 在线阅读"
  end

  def login_post
    @page_title = "登录迷蝴蝶 电子书在线阅读"
    @page_description = "登录迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "登录 电子书 在线阅读"
    user = User.find_by(email: params[:user][:email])
    unless user
      LoginEvents.log_invalid_user(params[:user][:email], request.remote_ip)
      flash.now[:error] = "Login error"
      render 'login' and return
    end
    unless User.verify_password?(params[:user][:password], user.password_hash, user.password_salt)
      LoginEvents.log_bad_password(user.id, request.remote_ip)
      flash.now[:error] = "Login error"
      render 'login' and return
    end
    # we remove any referral cookies when a user successfully logs in.  May solve the internet cafe problem
    # self.pop_captured_referral
    set_login(user)
    #TODO return_to_or(url(:home), :message => {:notice => "login_success"})
    flash[:notice] = "Login success"
    redirect_to root_url
  end

  def register
    @page_title = "注册迷蝴蝶 电子书在线阅读"
    @page_description = "注册迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "注册 电子书 在线阅读"
  end

  def register_post
    @page_title = "注册迷蝴蝶 电子书在线阅读"
    @page_description = "注册迷蝴蝶中文电子书网站，在线阅读最热门的中文电子书"
    @page_keywords = "注册 电子书 在线阅读"
    unless email_valid?(params[:user][:email])
      #TODO SystemEvents.log(:invalid_email_format, {:email => params[:email]})
      #TODO decide how to handle i18n and message by id
      #message[:error] = "invalid_email_format"
      flash.now[:error] = "invalid_email_format"
      render 'register' and return
    end
    unless params[:user][:password] == params[:user][:password_confirm]
      flash.now[:error] = "passwords_do_not_match"
      render 'register' and return
    end
    if User.find_by(email: params[:user][:email])
      #TODO dont tell user they are already registered?
      flash.now[:error] = "email_already_registered"
      render 'register' and return
    end
    user = User.new({:email => params[:user][:email], :registered => Time.now})
    #referral_code = self.pop_captured_referral
    #@user[:referred_by] = referral_code if referral_code
    user.set_password_hash(params[:user][:password])
    user.register_ip = request.remote_ip
    user.save
    UserEvents.log(user.id, :registered)
    set_login(user)
    send_user_mail(user.id, :welcome)
    #TODO return_to_or(url(:home), :message => {:notice => "registered_success"})
    flash[:notice] = "Login success"
    redirect_to root_url
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
    LoginEvents.log_success(user.id, request.remote_ip)
    session[:id] = user.id.to_s
  end

  def ensure_no_user
    if current_user
      flash[:notice] = "already logged in. back to root"
      redirect_to root_path
    end
  end
end
