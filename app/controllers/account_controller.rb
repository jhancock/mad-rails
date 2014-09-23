# -*- coding: utf-8 -*-
class AccountController < ApplicationController
  before_action :ensure_user

  def index
    @page_title = "账户管理"
    @page_description = "在线管理自己账户的密码和最近阅读的书签信息 "
    @page_keywords = "账户管理 书签 电子书"
  end

  def logout
    session[:id] = nil
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
        
  private
  def ensure_user
    unless current_user
      flash[:notice] = "unauthorized!. back to root"
      redirect_to root_path
    end
  end
end
