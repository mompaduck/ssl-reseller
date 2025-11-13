puts "== Seeding Products =="

Product.destroy_all

products = [
  # =========================
  # Single Domain SSL
  # =========================
  {
    category: "single_domain",
    name: "GoGetSSL Domain SSL",
    provider: "gogetssl",
    product_code: "GG-DV-001",
    description: "빠른 발급과 합리적인 가격의 도메인 검증(DV) SSL 인증서",
    duration_months: 12,
    price: 7000,
    domain_count: 1,
    validation_type: "DV",
    liability_usd: 50000,
    discount: 0,
    cert_type: "single_domain",
    multi_year_support: true,
    logo_url: "/images/logos/gogetssl.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://gogetssl.com",
    features: "- 빠른 발급\n- 99% 브라우저 호환\n- 무료 재발급 제공",
    is_active: true
  },
  {
    category: "single_domain",
    name: "Sectigo PositiveSSL",
    provider: "sectigo",
    product_code: "SECT-POS-001",
    description: "가성비 최고의 Sectigo PositiveSSL 도메인 인증서",
    duration_months: 12,
    price: 9000,
    domain_count: 1,
    validation_type: "DV",
    liability_usd: 50000,
    discount: 0,
    cert_type: "single_domain",
    multi_year_support: true,
    logo_url: "/images/logos/sectigo.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://sectigo.com",
    features: "- 즉시 발급\n- 256비트 암호화\n- 사이트 신뢰도 향상",
    is_active: true
  },

  # =========================
  # Wildcard SSL
  # =========================
  {
    category: "wildcard",
    name: "GoGetSSL Wildcard SSL",
    provider: "gogetssl",
    product_code: "GG-WC-001",
    description: "모든 서브도메인을 보호하는 Wildcard SSL 인증서",
    duration_months: 12,
    price: 49000,
    domain_count: 999,
    validation_type: "DV",
    liability_usd: 50000,
    discount: 10,
    cert_type: "wildcard",
    multi_year_support: true,
    logo_url: "/images/logos/gogetssl.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://gogetssl.com",
    features: "- Wildcard 보호\n- 서브도메인 무제한\n- 빠른 발급",
    is_active: true
  },
  {
    category: "wildcard",
    name: "Sectigo PositiveSSL Wildcard",
    provider: "sectigo",
    product_code: "SECT-POS-WC-001",
    description: "가장 많이 판매되는 Wildcard 도메인 인증서",
    duration_months: 12,
    price: 69000,
    domain_count: 999,
    validation_type: "DV",
    liability_usd: 50000,
    discount: 5,
    cert_type: "wildcard",
    multi_year_support: true,
    logo_url: "/images/logos/sectigo.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://sectigo.com",
    features: "- 무제한 서브도메인\n- 강력한 암호화",
    is_active: true
  },

  # =========================
  # Multi Domain SSL
  # =========================
  {
    category: "multi_domain",
    name: "GoGetSSL Multi Domain SSL",
    provider: "gogetssl",
    product_code: "GG-MD-001",
    description: "여러 도메인을 한 번에 보호하는 멀티 도메인 인증서",
    duration_months: 12,
    price: 38000,
    domain_count: 3,
    validation_type: "DV",
    liability_usd: 50000,
    discount: 0,
    cert_type: "multi_domain",
    multi_year_support: true,
    logo_url: "/images/logos/gogetssl.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://gogetssl.com",
    features: "- 최대 100개 도메인 확장 가능\n- 빠른 발급",
    is_active: true
  },
  {
    category: "multi_domain",
    name: "Sectigo PositiveSSL Multi Domain",
    provider: "sectigo",
    product_code: "SECT-POS-MD-001",
    description: "Sectigo에서 제공하는 Multi Domain 인증서",
    duration_months: 12,
    price: 43000,
    domain_count: 3,
    validation_type: "DV",
    liability_usd: 50000,
    discount: 0,
    cert_type: "multi_domain",
    multi_year_support: true,
    logo_url: "/images/logos/sectigo.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://sectigo.com",
    features: "- SAN 추가 가능\n- 비용 효율적 도메인 관리",
    is_active: true
  },

  # =========================
  # OV 인증서
  # =========================
  {
    category: "ov_certificate",
    name: "DigiCert Secure Site SSL",
    provider: "digicert",
    product_code: "DIGI-OV-001",
    description: "기업용 OV SSL 인증서로 최고 수준 신뢰도 제공",
    duration_months: 12,
    price: 320000,
    domain_count: 1,
    validation_type: "OV",
    liability_usd: 1500000,
    discount: 5,
    cert_type: "single_domain",
    multi_year_support: true,
    logo_url: "/images/logos/digicert.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://digicert.com",
    features: "- 기업 실사 검증\n- 최상급 브랜드 신뢰도",
    is_active: true
  },
  {
    category: "ov_certificate",
    name: "GeoTrust True BusinessID",
    provider: "geotrust",
    product_code: "GEO-OV-001",
    description: "기업 신뢰를 위한 OV 인증서",
    duration_months: 12,
    price: 145000,
    domain_count: 1,
    validation_type: "OV",
    liability_usd: 1250000,
    discount: 8,
    cert_type: "single_domain",
    multi_year_support: true,
    logo_url: "/images/logos/geotrust.png",
    warranty_url: "/guides/warranty",
    brand_site_url: "https://geotrust.com",
    features: "- OV 검증\n- 강력한 암호화",
    is_active: true
  }
]

Product.insert_all!(products)

puts "== Products Seeding Complete =="