# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :name, presence: true, on: :create
  # terms 검증은 회원가입 시에만
  validates :terms, acceptance: true, on: :create, if: -> { provider.blank? }

  has_many :orders, dependent: :destroy
  has_many :certificates, dependent: :destroy

  def self.from_omniauth(auth)
    Rails.logger.info "======== [OmniAuth] Finding or creating user with: #{auth.provider} - #{auth.uid} ========"
    
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize do |u|
      Rails.logger.info "[OmniAuth] New user initialization block."
      u.email = auth.info.email
      u.password = Devise.friendly_token[0, 20]
      u.name = auth.info.name || auth.info.email.split('@').first
    end

    # provider와 uid를 명시적으로 할당
    user.provider = auth.provider
    user.uid = auth.uid

    if user.persisted?
      Rails.logger.info "[OmniAuth] User exists. Checking for changes."
      if user.changed?
        Rails.logger.info "[OmniAuth] User has changes, attempting to save."
        saved = user.save
        Rails.logger.info "[OmniAuth] Save result for existing user: #{saved}. Errors: #{user.errors.full_messages.join(', ')}"
      else
        Rails.logger.info "[OmniAuth] User has no changes. No save needed."
      end
    else
      Rails.logger.info "[OmniAuth] New user. Attempting to save without validation."
      # 신규 사용자는 검증 없이 저장
      saved = user.save(validate: false)
      Rails.logger.info "[OmniAuth] Save result for new user: #{saved}. Errors: #{user.errors.full_messages.join(', ')}"
    end

    Rails.logger.info "[OmniAuth] Final user persisted state: #{user.persisted?}"
    Rails.logger.info "================================================================================"
    
    user
  end
end