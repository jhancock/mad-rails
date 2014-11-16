# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  attr_accessor :canonical_path

  require 'exceptions'
  rescue_from Unauthenticated, with: :unauthenticated
  rescue_from Unauthorized, with: :unauthorized

  protect_from_forgery with: :exception
  before_action :http_auth
  before_action :set_country
  before_action :current_user
  before_action :capture_referrer

  def current_user
    if @_current_user then return @_current_user end
    if session[:id]
      user = User.find(session[:id])
      if user
        @_current_user = user
      else
        reset_session
        @_current_user = nil
      end
    else
      @_current_user = nil
    end
    @_current_user
  end

  def unauthenticated(exception)
    session.delete(:auth_success_path)
    session.delete(:auth_success_message)
    session[:auth_success_path] = exception.success_path if exception.success_path
    session[:auth_success_message] = exception.success_message if exception.success_message
    flash[:notice] = exception.message if exception.message
    redirect_to exception.redirect_to || login_path
  end

  def unauthorized(exception)
    flash[:notice] = exception.message if exception.message
    redirect_to exception.redirect_to || root_path
  end

  def redirect_back_or(path, options = {})
    flash[:notice] = options[:notice] if options.key?(:notice)
    flash[:error] = options[:error] if options.key?(:error)
    referer = request.env["HTTP_REFERER"]
    if referer
      redirect_to :back
    else
      redirect_to path
    end
  end

  # set :cn in session cookie so we always know what country a user is from.  Even unregistered or not logged in users. 
  def set_country
    unless session[:cn]
      info = GeoIP.new(Rails.configuration.mihudie.geolitecity_path).city(request.remote_ip)
      if info
        session[:cn] = info.country_code2
      else
        session[:cn] = "unknown"
      end
    end
  end

  def china?
    session[:cn] == "CN"
  end

  def capture_referrer
    session[:referrer] = params["_r"] if params["_r"] && !current_user
  end

  # sort is "popular" or "recent".  return the Chinese for it.
  def sort_cn(sort)
    sort == "popular" ? "热力关注" : "recent"
  end

  def render_404
    render :file => "/public/404.html", :layout => false, :status => 404
  end

  def send_user_mail(user_id, method, hash = {})
    AsyncUserMailerJob.new.async.perform(user_id, method, hash)
  end

  def email_valid?(value)
    return true if value =~ /.+@.+\..+/i
    false

    # old check
    # return false if value =~ /\s/
    #return false if value =~ /;|,|:|\/|<|>|\s/
    # return true if value =~ /^.+@.+\..+$/
    #return true if value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    #false
  end

  def ensure_user
    raise Unauthenticated.new(message: "You must be logged in to view this page", success_path: request.original_fullpath) unless current_user
  end

  protected

  def http_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == "foo" && password == "bar"
    end
  end
end
