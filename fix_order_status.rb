# 기존 주문들의 status를 pending으로 설정하는 스크립트
# 실행: rails runner fix_order_status.rb

puts "주문 상태 업데이트 시작..."

# status가 nil인 주문들 찾기
orders_without_status = Order.where(status: nil)

if orders_without_status.empty?
  puts "상태가 없는 주문이 없습니다."
  exit
end

puts "총 #{orders_without_status.count}개의 주문에 기본 상태(pending) 설정 예정"

orders_without_status.each do |order|
  order.update_column(:status, 0)  # 0 = pending
  puts "  주문 ##{order.id} (#{order.internal_order_id}) → pending 설정"
end

puts "\n완료! 총 #{orders_without_status.count}개 주문의 상태가 업데이트되었습니다."
