class UsersController < ApplicationController
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id # log in after signup
      redirect_to movies_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.json {}
      format.js
      format.html 
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :firstname, :lastname, :password, :password_confirmation, :admin)
  end

end
