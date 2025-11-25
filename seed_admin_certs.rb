# Create some dummy data for Admin Certificate Dashboard verification

user = User.first
product = Product.first

puts "Seeding data for Admin Certificate Dashboard..."

# 1. Issued Certificate
order1 = Order.create!(
  user: user,
  product: product,
  domain: "issued-cert.com",
  total_price: 15000,
  status: "issued",
  payment_method: "card",
  certificate_type: "dv",
  name: "John Doe",
  english_name: "John Doe",
  company_name: "Example Corp",
  phone: "010-1234-5678",
  csr: "-----BEGIN CERTIFICATE REQUEST-----\nMOCK_CSR\n-----END CERTIFICATE REQUEST-----"
)
Certificate.create!(
  order: order1,
  user: user,
  status: :issued,
  certificate_type: :dv,
  issued_at: 2.days.ago,
  expires_at: 363.days.from_now,
  serial_number: "SEC-#{SecureRandom.hex(8).upcase}",
  certificate_body: "MOCK_CERT_BODY",
  dcv_method: "EMAIL",
  dcv_email: "admin@issued-cert.com"
)

# 2. DCV Failed Certificate
order2 = Order.create!(
  user: user,
  product: product,
  domain: "dcv-failed.com",
  total_price: 15000,
  status: "paid",
  payment_method: "card",
  certificate_type: "dv",
  name: "Jane Doe",
  english_name: "Jane Doe",
  company_name: "Fail Corp",
  phone: "010-9876-5432",
  csr: "-----BEGIN CERTIFICATE REQUEST-----\nMOCK_CSR\n-----END CERTIFICATE REQUEST-----"
)
Certificate.create!(
  order: order2,
  user: user,
  status: :dcv_failed,
  certificate_type: :dv,
  dcv_method: "DNS",
  dcv_cname_host: "_demo.dcv-failed.com",
  dcv_cname_value: "sectigo-verify.com",
  failure_reason: "DNS CNAME 레코드를 찾을 수 없습니다. (NXDOMAIN)"
)

# 3. Pending Certificate
order3 = Order.create!(
  user: user,
  product: product,
  domain: "pending-cert.com",
  total_price: 15000,
  status: "paid",
  payment_method: "card",
  certificate_type: "dv",
  name: "Pending User",
  english_name: "Pending User",
  company_name: "Pending Corp",
  phone: "010-1111-2222",
  csr: "-----BEGIN CERTIFICATE REQUEST-----\nMOCK_CSR\n-----END CERTIFICATE REQUEST-----"
)
Certificate.create!(
  order: order3,
  user: user,
  status: :pending,
  certificate_type: :dv,
  dcv_method: "HTTP",
  dcv_file_url: "http://pending-cert.com/.well-known/pki-validation/file.txt",
  dcv_file_content: "sectigo-verification-code"
)

puts "Seeding complete!"
