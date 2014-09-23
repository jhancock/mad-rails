class AdminUsersController < AdminController
  def index
  end

  def search
  end

  def search_post
    @user = User.find_by(email: params[:email])
    redirect_to admin_users_show_url(id: @user.id) and return if @user
    flash.now[:error] = "#{params[:email]} not found"
    render 'search'
  end

  def show
    @user = User.find(params[:id])
    unless @user
      flash[:error] = "User #{params[:id]} not found"
      redirect_to admin_users_search_url and return
    end
  end

  def remove
    @user = User.find(params[:id])
    unless @user
      flash[:error] = "User #{params[:id]} not found"
      redirect_to admin_users_search_url and return
    end
  end

  def remove_post
    @user = User.find(params[:id])
    unless @user
      flash[:error] = "User #{params[:id]} not found"
      redirect_to admin_users_search_url and return
    end
    @user.delete
    flash[:notice] = "User #{@user.email} - #{@user.id}"
    redirect_to admin_users_search_url  end
end
