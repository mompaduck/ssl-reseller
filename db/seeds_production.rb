# Production Seed Data for Testing

puts "🌱 Starting production seed data creation..."

# Clear existing data (optional - comment out if you want to keep existing data)
# puts "Clearing existing data..."
# Certificate.destroy_all
# Order.destroy_all
# Product.destroy_all
# User.where.not(email: 'test@example.com').destroy_all

# Create Products
puts "Creating products..."
products = [
  {
    name: "Sectigo PositiveSSL (DV)",
    validation_type: 0,
    domain_type: 0,
    duration_months: 12,
    price: 15000,
    category: "dv",
    provider: "Sectigo",
    product_code: "SECTIGO_DV_SINGLE"
  },
  {
    name: "Sectigo PositiveSSL Wildcard (DV)",
    validation_type: 0,
    domain_type: 1,
    duration_months: 12,
    price: 85000,
    category: "dv",
    provider: "Sectigo",
    product_code: "SECTIGO_DV_WILDCARD"
  },
  {
    name: "Sectigo OV SSL (OV)",
    validation_type: 1,
    domain_type: 0,
    duration_months: 12,
    price: 120000,
    category: "ov",
    provider: "Sectigo",
    product_code: "SECTIGO_OV_SINGLE"
  },
  {
    name: "Sectigo EV SSL (EV)",
    validation_type: 2,
    domain_type: 0,
    duration_months: 12,
    price: 350000,
    category: "ev",
    provider: "Sectigo",
    product_code: "SECTIGO_EV_SINGLE"
  }
]

products.each do |product_attrs|
  Product.find_or_create_by!(product_code: product_attrs[:product_code]) do |product|
    product.assign_attributes(product_attrs)
  end
end

puts "✅ Created #{Product.count} products"

# Create Users
puts "Creating users..."

# Super Admin
admin = User.find_or_create_by!(email: 'test@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Super Admin'
  user.role = :super_admin
  user.status = :active
  user.confirmed_at = Time.current
end

# Regular Users
users_data = [
  { email: 'user1@example.com', name: 'John Doe', company_name: 'Acme Corp', phone: '010-1234-5678' },
  { email: 'user2@example.com', name: 'Jane Smith', company_name: 'Tech Solutions', phone: '010-2345-6789' },
  { email: 'user3@example.com', name: 'Bob Johnson', company_name: 'Web Services Inc', phone: '010-3456-7890' },
  { email: 'partner@example.com', name: 'Partner User', company_name: 'Partner Co', phone: '010-4567-8901' }
]

regular_users = users_data.map do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.name = user_data[:name]
    user.company_name = user_data[:company_name]
    user.phone = user_data[:phone]
    user.role = user_data[:email] == 'partner@example.com' ? :partner : :user
    user.status = :active
    user.confirmed_at = Time.current
  end
end

puts "✅ Created #{User.count} users"

# Create Orders and Certificates
puts "Creating orders and certificates..."

order_data = [
  {
    user: regular_users[0],
    product: Product.find_by(category: 'dv', domain_type: 0),
    domain: 'example.com',
    status: 'issued',
    cert_status: 'issued',
    cert_type: 'dv',
    dcv_method: 'EMAIL'
  },
  {
    user: regular_users[0],
    product: Product.find_by(category: 'dv', domain_type: 1),
    domain: '*.wildcard-test.com',
    status: 'paid',
    cert_status: 'pending',
    cert_type: 'dv',
    dcv_method: 'DNS'
  },
  {
    user: regular_users[1],
    product: Product.find_by(category: 'ov'),
    domain: 'secure.techsolutions.com',
    status: 'issued',
    cert_status: 'issued',
    cert_type: 'ov',
    dcv_method: 'HTTP'
  },
  {
    user: regular_users[1],
    product: Product.find_by(category: 'dv', domain_type: 0),
    domain: 'test.techsolutions.com',
    status: 'paid',
    cert_status: 'dcv_failed',
    cert_type: 'dv',
    dcv_method: 'EMAIL'
  },
  {
    user: regular_users[2],
    product: Product.find_by(category: 'ev'),
    domain: 'www.webservices.com',
    status: 'pending',
    cert_status: 'pending',
    cert_type: 'ev',
    dcv_method: 'EMAIL'
  },
  {
    user: regular_users[3],
    product: Product.find_by(category: 'dv', domain_type: 0),
    domain: 'partner.example.com',
    status: 'issued',
    cert_status: 'issued',
    cert_type: 'dv',
    dcv_method: 'DNS'
  }
]

order_data.each do |data|
  order = Order.create!(
    user: data[:user],
    product: data[:product],
    domain: data[:domain],
    certificate_type: data[:cert_type],
    status: data[:status],
    quantity: 1,
    total_price: data[:product].price,
    name: data[:user].name,
    english_name: data[:user].name.split.reverse.join(' '),
    company_name: data[:user].company_name,
    phone: data[:user].phone,
    csr: "-----BEGIN CERTIFICATE REQUEST-----\nMIICvjCCAaYCAQAweTELMAkGA1UEBhMCS1IxDjAMBgNVBAgMBVNlb3VsMQ4wDAYD\nVQQHDAVTZW91bDEMMAoGA1UECgwDQUNNRTEMMAoGA1UECwwDREVWMR4wHAYDVQQD\nDBVleGFtcGxlLmV4YW1wbGUuY29tMRAwDgYJKoZIhvcNAQkBFgFhMIIBIjANBgkq\n-----END CERTIFICATE REQUEST-----"
  )

  certificate = Certificate.create!(
    order: order,
    user: data[:user],
    certificate_type: data[:cert_type],
    status: data[:cert_status],
    dcv_method: data[:dcv_method],
    serial_number: data[:cert_status] == 'issued' ? "SN#{rand(100000..999999)}" : nil,
    issued_at: data[:cert_status] == 'issued' ? rand(1..30).days.ago : nil,
    expires_at: data[:cert_status] == 'issued' ? rand(300..400).days.from_now : nil,
    dcv_email: "admin@#{data[:domain].gsub('*.', '')}",
    failure_reason: data[:cert_status] == 'dcv_failed' ? 'DCV 이메일 승인 시간 초과' : nil,
    certificate_body: data[:cert_status] == 'issued' ? "-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAKo...DUMMY...CERTIFICATE...DATA...\n-----END CERTIFICATE-----" : nil
  )

  # Create Audit Logs
  AuditLog.create!(
    user: admin,
    auditable: order,
    action: 'create',
    message: "주문 생성: #{order.domain}",
    metadata: { status: order.status },
    ip_address: '127.0.0.1'
  )

  if data[:cert_status] == 'issued'
    AuditLog.create!(
      user: admin,
      auditable: certificate,
      action: 'status_change',
      message: "인증서 발급 완료: #{certificate.order.domain}",
      metadata: { old_status: 'pending', new_status: 'issued' },
      ip_address: '127.0.0.1'
    )
  end
end

puts "✅ Created #{Order.count} orders"
puts "✅ Created #{Certificate.count} certificates"
puts "✅ Created #{AuditLog.count} audit logs"

# Summary
puts "\n" + "="*50
puts "🎉 Production seed data creation completed!"
puts "="*50
puts "
📊 Summary:
- Products: #{Product.count}
- Users: #{User.count}
- Orders: #{Order.count}
- Certificates: #{Certificate.count}
- Audit Logs: #{AuditLog.count}

👤 Login credentials:
- Super Admin: test@example.com / password123
- User 1: user1@example.com / password123
- User 2: user2@example.com / password123
- User 3: user3@example.com / password123
- Partner: partner@example.com / password123
"
puts "="*50
