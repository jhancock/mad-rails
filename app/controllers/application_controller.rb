class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	before_action :current_user

	def current_user
		session[:id] ? @_current_user ||= User.find(session[:id]) : nil
	end

	def render_404
		render :file => "/public/404.html", :layout => false, :status => 404
	end

	def email_valid?(value)
		# return false if value =~ /\s/
		return false if value =~ /;|,|:|\/|<|>|\s/
		# return true if value =~ /^.+@.+\..+$/
		return true if value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    	false
	end
end
