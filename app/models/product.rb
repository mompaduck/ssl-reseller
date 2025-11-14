# app/models/product.rb
class Product < ApplicationRecord
  # ============================
  # ENUMS (정수 기반)
  # ============================

  enum :domain_type, {
    single:   0,
    wildcard: 1,
    multi:    2
  }, prefix: true

  enum :validation_type, {
    dv: 0,
    ov: 1,
    ev: 2
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

  def auto_name
    "#{provider} #{validation_type.upcase} #{DOMAIN_LABEL[domain_type]} SSL"
  end
end