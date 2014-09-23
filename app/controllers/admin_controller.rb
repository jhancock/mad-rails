class AdminController < ApplicationController
  before_action :ensure_admin

  #layout "admin"
  
  def admin_controller?
    true
  end
  
  def ensure_admin
    unless current_user && current_user.admin
      flash[:error] = "Unauthorized!"
      redirect_to :root
    end
  end

  def index
  end
end
