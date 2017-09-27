require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  #Signup失敗時のテスト
  test "invalid signup information" do
    get signup_path
    
    #POST先が正しいかのテスト
    assert_select "form[action=?]", signup_path
    
    #不正なUserデータをPOSTしてテスト
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation"
    assert_select 'div.field_with_errors'
    assert_select 'ul' do
      assert_select 'li', 'Name can\'t be blank'
      assert_select 'li', 'Email is invalid'
      assert_select 'li', 'Password confirmation doesn\'t match Password'
      #パスワードの文字数制限が変わった時のため、文字数部分のエラーメッセージより前で部分一致を検証
      assert_select 'li', /Password is too short*/
    end
  end
  
  #Signup成功時のテスト
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash[:success].blank?
    assert is_logged_in? #ユーザ登録後すぐにログインされているかのテスト
  end
  
end
