require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear 
    @user = users(:michael)
  end
  
  test "password resets" do
    get new_password_reset_path
    assert_template "password_resets/new"
    #無効なメールアドレスをPOSTしてみる
    post password_resets_path, params: {password_reset: {email: "" } }
    assert_not flash.empty?  #何らかのflash messageが入っているか？
    assert_template "password_resets/new"  #同じフォームが表示されているか？
    #有効なメールアドレスをPOSTする
    post password_resets_path, params: {password_reset: {email: @user.email} }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest   #POST前後でダイジェスト値は変わっているか？
    assert_equal 1, ActionMailer::Base.deliveries.size  #配信されたメールはきっかり1通のみか
    assert_not flash.empty?
    assert_redirected_to root_url
    #以下、パスワード再設定フォームのテスト（createアクション）
    user = assigns(:user)  #assigns関数でcreateアクション内のインスタンス変数@userを取得
    #GETしたパス内のメールアドレスが無効な場合
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    #GETしたパス内のトークンが無効な場合
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url
    #GETしたユーザーが無効だった場合
    user.toggle!(:activated)  #activated属性を変更
    get edit_password_reset_path(user.reset_token, email: user.email)
    user.toggle!(:activated)  #元に戻しておく
    #正常動作の場合（アドレス、トークンともに有効）、パスワード変更フォームを表示
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", user.email
    #以下、パスワード変更フォーム（updateアクション）のテスト
    #パスワード確認欄が不一致の場合
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                 user: { password: "hogehoge", 
                         password_confirmation: "abcdef" } }
    assert_select "div#error_explanation"
    #パスワードが空の場合
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                 user: { password: "", 
                         password_confirmation: "" } }
    assert_select "div#error_explanation"
    #パスワードが短い場合
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                 user: { password: "abc", 
                         password_confirmation: "abc" } }
    assert_select "div#error_explanation"
    #正常動作（有効なパスワード）の場合
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                 user: { password: "hogehoge", 
                         password_confirmation: "hogehoge" } }
    assert is_logged_in?
    assert_nil user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end
  
  #トークンが期限切れになった時のテスト
  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: {password_reset: {email: @user.email} }
    user = assigns(:user)
    user.update_attribute(:reset_sent_at, 3.hours.ago)  #3時間経過させて期限切れにする
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                 user: { password: "hogehoge", 
                         password_confirmation: "hogehoge" } }
    assert_response :redirect
    follow_redirect!
    assert_match "expired", response.body  #flash messageの文字列で判別する
  end
end
