class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user  #ユーザが作成されたら自動的にログインする
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user  #ユーザのページへリダイレクト
    else
      render 'new'
    end
  end

  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
