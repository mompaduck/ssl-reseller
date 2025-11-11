class User < ApplicationRecord
  # 다음 모듈들이 포함되어 있어야 합니다. :authenticate_user!는 User 모델에 Devise 모듈이 설정되어 있어야 작동합니다.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable  #, :confirmable

  before_validation :sanitize_phone_number

  validates :name, presence: true
  validates :terms, acceptance: true
  validates :phone,
          allow_blank: true,
          format: { with: /\A(01[016789])\d{7,8}\z/, message: "올바른 전화번호 형식이 아닙니다 (예: 010-1234-5678)" }
          
  has_many :orders, dependent: :destroy

  private

  def sanitize_phone_number
    if phone.present?
      self.phone = phone.gsub(/\D/, '')
    end
  end
end