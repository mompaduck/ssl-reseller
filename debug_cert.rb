STDOUT.sync = true
user = User.first
order = Order.last
service = SslProviderService.new
cert = Certificate.new(
  order: order,
  user: order.user,
  certificate_type: order.certificate_type,
  status: :issued,
  issued_at: Time.current,
  expires_at: 1.year.from_now,
  serial_number: SecureRandom.hex(10),
  certificate_body: service.fetch_certificate("test")
)
if cert.save
  puts "Success"
else
  puts "Failed: #{cert.errors.full_messages}"
end
