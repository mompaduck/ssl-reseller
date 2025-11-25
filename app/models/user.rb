# app/models/user.rb
class User < ApplicationRecord
  include Authorization
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # terms 검증은 회원가입 시에만
  validates :terms, acceptance: true, on: :create, if: -> { provider.blank? }

  has_many :orders, dependent: :destroy
  has_many :certificates, dependent: :destroy
  belongs_to :assigned_partner, class_name: 'User', optional: true
  has_many :assigned_users, class_name: 'User', foreign_key: :assigned_partner_id
  has_many :audit_logs, as: :auditable

  enum :role, {
    user: 0,
    partner: 1,
    support: 2,
    admin: 3,
    super_admin: 4
  }, default: :user

  enum :status, {
    active: 0,
    pending: 1,
    banned: 2
  }, default: :active

  def self.from_omniauth(auth)
    # provider와 uid로 먼저 사용자를 찾습니다.
    user = where(provider: auth.provider, uid: auth.uid).first

    # 만약 provider/uid로 찾지 못했다면, 이메일로 찾습니다.
    # (일반 회원가입을 먼저 한 사용자가 구글 로그인을 시도하는 경우)
    if user.nil?
      user = where(email: auth.info.email).first_or_initialize
    end

    # 사용자 정보 업데이트 (신규 및 기존 사용자 모두에게 적용)
    user.provider = auth.provider
    user.uid      = auth.uid
    user.email    = auth.info.email
    user.name     = auth.info.name if user.name.blank?
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    
    # 약관 동의 처리 (신규 사용자의 경우)
    user.terms = '1' if user.new_record?

    user.save
    user
  end
end