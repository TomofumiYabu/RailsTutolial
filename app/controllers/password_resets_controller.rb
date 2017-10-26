class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  #パスワード再設定有効期限切れ対策
  
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions."
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if params[:user][:password].empty?    #再設定フォームでパスワードが空文字のケース
      @user.errors.add(:password, :blank)  #パスワードがblankというエラーメッセージをuserオブジェクトに入れる
      render 'edit'                       #再設定フォームを再度描画
    elsif @user.update_attributes(user_params)  #正常にパスワードが更新できたとき
      log_in @user                              #自動でログインする
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else                                  #無効なパスワードの場合
      render 'edit'                       #再設定フォームを再描画（エラーメッセージはUserでValidateされているはず）
    end 
  end
    
  private
  
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  
    #beforeフィルタ
  
    def get_user
      @user = User.find_by(email: params[:email])
    end
    
    #正しいユーザーかどうかを確認し、違う場合はルートへリダイレクト
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
    
    #トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
  
end
