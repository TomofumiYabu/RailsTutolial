require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
  end
  
  test "layout links for logged in user" do
    log_in_as(@user)
    get root_path
    assert_select "a[href=?]", users_path
  end
  
  test "layout links for not logged in user" do
    log_in_as(@user)
    delete logout_path  #一度ログアウトする
    get root_path
    assert_select "a[href=?]", users_path, false
  end
  
end
