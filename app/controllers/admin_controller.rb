class AdminController < ApplicationController
  before_action :ensure_admin

  #layout "admin"
  
  def admin_controller?
    true
  end
  
  def ensure_admin
    raise Unauthorized.new() unless current_user && current_user.admin?
  end

  def index
  end
end
