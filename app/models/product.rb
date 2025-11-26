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

  # 상품 코드용 약어
  DOMAIN_CODE = {
    "single" => "SD",
    "wildcard" => "WC",
    "multi" => "MD"
  }.freeze

  VALIDATION_CODE = {
    "dv" => "DV",
    "ov" => "OV",
    "ev" => "EV"
  }.freeze

  # ============================
  # VALIDATIONS
  # ============================
  validates :name, presence: true
  validates :product_code, presence: true, uniqueness: true
  validates :cost_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :selling_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }
  validates :domain_type, presence: true, inclusion: { in: domain_types.keys }
  validates :validation_type, presence: true, inclusion: { in: validation_types.keys }
  validates :discount, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :margin_percentage, numericality: true, allow_nil: true

  # ============================
  # CALLBACKS
  # ============================
  before_save :calculate_margin

  # ============================
  # SCOPES
  # ============================
  scope :active, -> { where(is_active: true) }
  scope :on_promotion, -> { where(is_on_promotion: true).where('promo_valid_until > ?', Time.current) }
  scope :profitable, -> { where('selling_price > cost_price') }

  # ============================
  # METHODS
  # ============================
  
  # 마진율 자동 계산
  def calculate_margin
    return if cost_price.zero?
    self.margin_percentage = ((selling_price - cost_price).to_f / cost_price * 100).round(2)
  end

  # 할인 적용 후 최종 가격
  def final_price
    return selling_price if discount.zero?
    (selling_price * (1 - discount / 100.0)).to_i
  end

  # 순이익 (최종가 - 원가)
  def profit
    final_price - cost_price
  end

  # 이익률 (%)
  def profit_percentage
    return 0 if cost_price.zero?
    ((profit.to_f / cost_price) * 100).round(2)
  end

  # 프로모션 활성화 여부
  def active_promotion?
    is_on_promotion && promo_valid_until&.future?
  end

  # 자동 이름 생성
  def auto_name
    "#{provider} #{validation_type.upcase} #{DOMAIN_LABEL[domain_type]} SSL"
  end

  # 상품 코드 자동 생성
  # 형식: {CA}-{TYPE}-{SCOPE}-{YEARS}
  # 예: SECTIGO-DV-SD-1Y, SECTIGO-DV-SD-30D
  def generate_product_code
    ca = provider.upcase.gsub(/\s+/, '')
    type = VALIDATION_CODE[validation_type]
    scope = DOMAIN_CODE[domain_type]
    
    # 기간 계산: 12개월 이상이면 년(Y), 미만이면 일(D) 또는 개월(M)
    if duration_months >= 12 && (duration_months % 12).zero?
      period = "#{(duration_months / 12)}Y"
    elsif duration_months >= 1
      # 개월 단위를 일수로 환산 (1개월 = 30일)
      days = duration_months * 30
      period = "#{days}D"
    else
      period = "0D"
    end
    
    "#{ca}-#{type}-#{scope}-#{period}"
  end

  # 상품 코드를 설정하거나 자동 생성
  def auto_product_code
    self.product_code = generate_product_code if product_code.blank?
  end
end