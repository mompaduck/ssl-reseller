class User < ApplicationRecord
  include Authorization
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :terms, acceptance: true, on: :create, if: -> { provider.blank? }

  has_many :orders, dependent: :restrict_with_error
  has_many :certificates, dependent: :restrict_with_error
  belongs_to :assigned_partner, class_name: 'User', optional: true
  has_many :assigned_users, class_name: 'User', foreign_key: :assigned_partner_id
  has_many :audit_logs, as: :auditable

  enum :role, { user: 0, partner: 1, support: 2, admin: 3, super_admin: 4 }, default: :user
  enum :status, { active: 0, pending: 1, banned: 2 }, default: :active


  # 수정된 Omniauth 방식
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email
    user.name = auth.info.name if user.name.blank?
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.provider = auth.provider
    user.uid = auth.uid

    # 구글 로그인 사용자는 이메일 인증 필요 없음
    user.confirmed_at ||= Time.current

    user.save
    user
  end

  # Check if user is soft deleted
  def deleted?
    deleted_at.present?
  end

  # Prevent deleted users from logging in
  def active_for_authentication?
    super && !deleted?
  end

  # Custom message for deleted accounts
  def inactive_message
    deleted? ? :deleted_account : super
  end
end