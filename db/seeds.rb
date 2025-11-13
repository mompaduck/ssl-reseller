puts "=== Auto Generating SSL Products (approx 30) ==="

Product.destroy_all

providers = {
  sectigo:   0,
  comodo:    1,
  digicert:  2,
  rapidssl:  3,
  certum:    4,
  thawte:    5,
  geotrust:  6
}

cert_types = {
  single: "single",
  wildcard: "wildcard",
  multi: "multi",
  ev: "ev"
}

domain_count_map = {
  single: 1,
  wildcard: 999,
  multi: 5,
  ev: 1
}

base_prices = {
  single: 9000,
  wildcard: 70000,
  multi: 50000,
  ev: 150000
}

liabilities = [10_000, 25_000, 50_000, 250_000, 500_000, 1_000_000]

products_created = 0

providers.each do |prov, prov_code|
  cert_types.each do |ctype, ctype_value|

    # 같은 provider × cert_type 조합에 대해 1~2개 생성
    rand(1..2).times do
      name = "#{prov.to_s.capitalize} #{ctype.to_s.capitalize} SSL"
      product_code = "#{prov.to_s[0..2].upcase}-#{ctype.to_s[0..2].upcase}-#{SecureRandom.hex(2).upcase}"

      Product.create!(
        name: name,
        provider: prov,
        cert_type: ctype,
        category: ctype,  # 필터 UI와 동일 구조(single/wildcard/multi/ev)
        product_code: product_code,
        description: "#{name} 상품입니다. #{prov.to_s.capitalize}에서 제공하는 #{ctype.to_s.capitalize} SSL 인증서.",
        duration_months: [12, 24, 36].sample,
        price: base_prices[ctype] + rand(1000..8000),
        domain_count: domain_count_map[ctype],
        validation_type: [:DV, :OV, :EV].sample,
        liability_usd: liabilities.sample,
        discount: [0, 5, 10, 20, 30].sample,
        multi_year_support: [true, false].sample,
        logo_url: nil,
        warranty_url: nil,
        brand_site_url: "https://#{prov}.com",
        features: "- Strong Encryption\n- Fast Issuance\n- Browser Compatibility",
        is_active: true
      )

      products_created += 1
    end
  end
end

puts "=== #{products_created} products created successfully ==="