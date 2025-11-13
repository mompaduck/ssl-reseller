class Product < ApplicationRecord
  # ============================
  # ENUMS (문자열 기반)
  # ============================

  enum :domain_type, {
    single:   "single",
    wildcard: "wildcard",
    multi:    "multi"
  }, prefix: true

  enum :validation_type, {
    DV: "DV",
    OV: "OV",
    EV: "EV"
  }

  PROVIDERS = [
    "Sectigo",
    "DigiCert",
    "RapidSSL",
    "Certum",
    "Thawte",
    "GeoTrust"
  ].freeze

  validates :provider, presence: true, inclusion: { in: PROVIDERS }

  DOMAIN_LABEL = {
    "single" => "Single Domain",
    "wildcard" => "Wildcard",
    "multi" => "Multi Domain"
  }.freeze

  validates :name, presence: true
  validates :product_code, presence: true, uniqueness: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }
  validates :domain_type, presence: true, inclusion: { in: domain_types.keys }
  validates :validation_type, presence: true, inclusion: { in: validation_types.keys }

  scope :active, -> { where(is_active: true) }

  # 자동 이름 생성
  def auto_name
    "#{provider} #{validation_type} #{DOMAIN_LABEL[domain_type]} SSL"
  end
end