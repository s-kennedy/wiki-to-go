class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :set_user_books
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
  	if session[:user_id]
  	  @current_user ||= User.find session[:user_id]
  	end
  end

  def set_user_books
    if current_user
      @user = current_user
      @user_wikis = @user.books.order(updated_at: :desc).limit(5)
    end
  end

  def disable_footer
    @disable_footer = true
  end

  def require_login
    unless current_user
      flash[:error] = 'Please log in or register to access this page'
      redirect_to root_path
    end
  end

end
