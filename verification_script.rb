# verification_script.rb
user = User.first || User.create!(
  email: "test@example.com", 
  password: "password", 
  name: "Test User", 
  terms: "1"
)

puts "User: #{user.email}"

# Create Product if not exists
product = Product.find_or_create_by!(
  name: "dv", 
  product_code: "dv_ssl", 
  price: 10000, 
  duration_months: 12, 
  domain_type: :single, 
  validation_type: :dv,
  provider: "Sectigo"
)

puts "Product: #{product.name}"

# Simulate Order Creation
order = user.orders.build(
  certificate_type: "dv",
  domain: "example.com",
  company_name: "Test Company",
  phone: "010-1234-5678",
  company_address: "Seoul",
  product: product,
  total_price: 10000
)

if order.save
  puts "Order created: #{order.id} - Status: #{order.status}"
else
  puts "Order creation failed: #{order.errors.full_messages}"
  exit
end

# Simulate Payment and Issuance (Logic from OrdersController#pay)
puts "Simulating Payment..."
if order.update(status: :paid)
  puts "Order Paid"
  
  begin
    order.payments.create!(
      amount: order.total_price,
      payment_method: 'stripe',
      status: :succeeded,
      transaction_id: "tx_#{SecureRandom.hex(8)}"
    )
    puts "Payment record created"
  rescue => e
    puts "Payment creation failed: #{e.message}"
    puts e.backtrace
    exit
  end

  # Simulate Service Call
  service = SslProviderService.new
  csr = "-----BEGIN CERTIFICATE REQUEST-----\nMOCK_CSR\n-----END CERTIFICATE REQUEST-----"
  result = service.place_order(order, csr)

  if result.success?
    order.update(status: :issued, partner_order_number: result.order_id)
    puts "Order Issued. Partner Order ID: #{order.partner_order_number}"
    
    begin
      Certificate.create!(
        order: order,
        user: order.user,
        certificate_type: order.certificate_type,
        status: :issued,
        issued_at: Time.current,
        expires_at: 1.year.from_now,
        serial_number: SecureRandom.hex(10),
        certificate_body: service.fetch_certificate(result.order_id)
      )
      puts "Certificate Created"
    rescue => e
      puts "Certificate creation failed: #{e.message}"
      puts e.backtrace
      exit
    end
  else
    puts "Service call failed"
  end

else
  puts "Payment update failed"
end

puts "Final Order Status: #{order.reload.status}"
puts "Certificate Count: #{order.certificate ? 1 : 0}"
