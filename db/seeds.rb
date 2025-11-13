puts "=== SSL Product Seeds Generator (Provider × Validation × Domain) ==="

# ============================
# SEED SOURCE DATA
# ============================

PROVIDERS = [
  "Sectigo",
  "DigiCert",
  "RapidSSL",
  "Certum",
  "Thawte",
  "GeoTrust"
].freeze

VALIDATION_TYPES = ["DV", "OV", "EV"].freeze

DOMAIN_TYPES = {
  "single"   => "Single Domain",
  "wildcard" => "Wildcard Domain",
  "multi"    => "Multi Domain"
}.freeze

# 랜덤 기본 설명 생성기
def random_description(provider, vtype, dtype)
  <<~DESC
    #{provider}의 #{vtype} #{DOMAIN_TYPES[dtype]} SSL 인증서입니다.
    빠른 발급과 높은 호환성, 강력한 암호화를 제공합니다.
    CertGate 공식 리셀러를 통해 안정적으로 구매할 수 있습니다.
  DESC
end

# 랜덤 특징 생성기
def random_features(provider, vtype)
  [
    "최신 256-bit 암호화 제공",
    "99.9% 브라우저 호환성",
    "#{provider} 글로벌 인증기관",
    "#{vtype} 검증 방식 적용",
    "무료 재발급 지원",
    "모바일 최적화 호환성"
  ].join("\n")
end


# ============================
# SEED START
# ============================

Product.destroy_all
puts "→ 기존 Product 레코드 삭제 완료"

count = 0

PROVIDERS.each do |provider|
  VALIDATION_TYPES.each do |vtype|
    DOMAIN_TYPES.each do |dtype_key, dtype_label|

      price_base = case vtype
                   when "DV" then 15000
                   when "OV" then 89000
                   when "EV" then 189000
                   end

      price = price_base + rand(0..4) * 10000

      product = Product.create!(
        provider: provider,
        validation_type: vtype,
        domain_type: dtype_key,
        name: "#{provider} #{vtype} #{dtype_label} SSL",
        product_code: "#{provider[0..2].upcase}-#{vtype}-#{dtype_key.upcase}-#{rand(1000..9999)}",
        price: price,
        discount: [0, 5, 10, 15].sample,
        duration_months: [12, 24].sample,
        domain_count: (dtype_key == "multi" ? [3, 5, 10].sample : 1),
        liability_usd: [10000, 50000, 100000, 250000, 500000].sample,
        description: random_description(provider, vtype, dtype_key),
        features: random_features(provider, vtype),
        brand_site_url: "https://#{provider.downcase}.com",
        logo_url: "",
        warranty_url: "",
        multi_year_support: [true, false].sample,
        is_active: true
      )

      count += 1
      puts "✔ 생성됨: #{product.name}"
    end
  end
end

puts "=== SEED 완료 (총 #{count}개 생성됨) ==="