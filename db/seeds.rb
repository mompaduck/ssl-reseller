puts "Seeding database..."

require 'bcrypt' unless defined?(BCrypt)

admin = User.create!(name: "Admin User", email: "admin@certgate.local", encrypted_password: BCrypt::Password.create("admin1234"), role: "admin")
reseller = User.create!(name: "CertGate Reseller", email: "reseller@certgate.local", encrypted_password: BCrypt::Password.create("reseller1234"), role: "reseller", company_name: "CertGate", phone: "+82-10-1234-5678", country: "Korea")
user = User.create!(name: "Test User", email: "user@certgate.local", encrypted_password: BCrypt::Password.create("user1234"), role: "user")

sectigo = Product.create!(provider: "Sectigo", name: "PositiveSSL DV", description: "Quick domain validation SSL certificate from Sectigo.", ssl_type: "DV", price: 15000, validity_months: 12)
digicert = Product.create!(provider: "DigiCert", name: "DigiCert Secure Site OV", description: "Organization validated SSL certificate from DigiCert.", ssl_type: "OV", price: 89000, validity_months: 12)
digicert_ev = Product.create!(provider: "DigiCert", name: "DigiCert Secure Site EV", description: "Extended validation SSL with green bar.", ssl_type: "EV", price: 199000, validity_months: 12)

order = Order.create!(user: user, product: sectigo, reseller_id: reseller.id, domain_name: "example.com", csr: "-----BEGIN CERTIFICATE REQUEST----- ...", status: "issued", partner_order_id: "TEST123456", issued_at: Time.current, expires_at: 1.year.from_now)

Payment.create!(order: order, gateway: "stripe", transaction_id: "TXN123456789", amount: 15000, status: "paid", paid_at: Time.current)

Settlement.create!(reseller_id: reseller.id, total_amount: 15000, commission_rate: 15.0, status: "approved", paid_at: Time.current)

puts "✅ Seeding complete!"
