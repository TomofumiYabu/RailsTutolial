class User < ApplicationRecord
  #DB保存前にemail属性を強制的にに小文字へ変換
  before_save { self.email = email.downcase }
  
  #nameの検証
  validates :name,  presence: true, length: { maximum: 50 }
  
  #emailの検証
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                   format: {with: VALID_EMAIL_REGEX },
                   uniqueness:  { case_sensitive: false }
                   

end