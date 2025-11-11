class Product < ApplicationRecord
  # enum 형태로 cert_type, validation_type 설정
  enum cert_type: {
    single_domain:  "single_domain",
    wildcard:       "wildcard",
    multi_domain:   "multi_domain",
    ev_certificate: "ev_certificate"
  }, _suffix: true


  enum :validation_type, {
    DV: "DV",
    OV: "OV",
    EV: "EV"
  }

   enum :provider, {
    sectigo:   0,
    comodo:    1,
    digicert:  2,
    rapidssl:  3,
    certum:    4,
    thawte:    5,
    geotrust:  6
  }

  # 검증(validation)
  validates :name,          presence: true
  validates :product_code,  presence: true, uniqueness: true
  validates :price,         numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }
  validates :cert_type,     presence: true, inclusion: { in: cert_types.keys }
  validates :validation_type, presence: true, inclusion: { in: validation_types.keys }

  # scope
  scope :active, -> { where(is_active: true) }
end