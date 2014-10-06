class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :http_auth
  before_action :set_country
  before_action :current_user

  def current_user
    if @_current_user then return @_current_user end
    if session[:id]
      user = User.find(session[:id])
      if user
        #logger.info "user with id #{session[:id]} FOUND"
        @_current_user = user
      else
        #logger.info "user with id #{session[:id]} NOT FOUND. reseting session"
        reset_session
        #cookies.delete Rails.configuration.mihudie.session_cookie_name
        @_current_user = nil
      end
    else
      #logger.info "no user id in session"
      @_current_user = nil
    end
    @_current_user
  end

  # set :cn in session cookie so we always know what country a user is from.  Even unregistered and not logged in users. 
  def set_country
    unless session[:cn]
      info = GeoIP.new(Rails.root.join(Rails.configuration.mihudie.geolitecity_path)).city(request.remote_ip)
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

  def render_404
    render :file => "/public/404.html", :layout => false, :status => 404
  end

  def send_mail(mailer, method, *args)
    AsyncMailerJob.new.async.perform(mailer, method, *args)
  end

  def email_valid?(value)
    # return false if value =~ /\s/
    return false if value =~ /;|,|:|\/|<|>|\s/
    # return true if value =~ /^.+@.+\..+$/
    return true if value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    false
  end

  protected

  def http_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == "foo" && password == "bar"
    end
  end
end
