require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination' #Homeにページネーションはあるか？
    #無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    #有効な送信
    words = "テスト文章"
    assert_difference 'Micropost.count' , 1 do
      post microposts_path, params: { micropost: { content: words } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match words, response.body
    #投稿を削除する
    assert_select 'a', text: 'delete'
    first_mircopost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_mircopost)
    end
    #違うユーザのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count:0
  end
  
end
