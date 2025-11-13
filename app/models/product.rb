class Product < ApplicationRecord
  # 문자열 기반 enum 방식 (cert_type)
enum :cert_type, {
  single:     "single",
  wildcard:   "wildcard",
  multi:      "multi",
  ev:         "ev"
}, prefix: true

  # 문자열 기반 enum 방식 (validation_type)
  enum :validation_type, {
    DV: "DV",
    OV: "OV",
    EV: "EV"
  }

  # 정수 기반 enum 방식 (provider)
  enum :provider, {
    sectigo:  0,
    comodo:   1,
    digicert: 2,
    rapidssl: 3,
    certum:   4,
    thawte:   5,
    geotrust: 6
  }

  # Validations
  validates :name,            presence: true
  validates :product_code,    presence: true, uniqueness: true
  validates :price,           numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }
  validates :cert_type,       presence: true, inclusion: { in: cert_types.keys }
  validates :validation_type, presence: true, inclusion: { in: validation_types.keys }

  scope :active, -> { where(is_active: true) }
end