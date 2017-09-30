class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }    #DB保存前にemail属性を強制的に小文字へ変換
  validates :name,  presence: true, length: { maximum: 50 }    #nameの検証
  #emailの検証
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                   format: {with: VALID_EMAIL_REGEX },
                   uniqueness:  { case_sensitive: false }
  #セキュアなパスワード                 
  has_secure_password
  #passwordの検証
  validates :password, presence: true, length: { minimum: 6 }
  
  #渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
    # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
end