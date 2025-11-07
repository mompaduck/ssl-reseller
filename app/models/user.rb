class User < ApplicationRecord
  # 다음 모듈들이 포함되어 있어야 합니다. :authenticate_user!는 User 모델에 Devise 모듈이 설정되어 있어야 작동합니다.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
