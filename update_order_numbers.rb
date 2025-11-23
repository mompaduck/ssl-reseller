# 기존 주문들에 주문번호 부여하는 스크립트
# 실행: rails runner update_order_numbers.rb

puts "기존 주문에 주문번호 부여 시작..."

# internal_order_id가 없는 주문들을 날짜별로 그룹화
orders_without_number = Order.where(internal_order_id: [nil, '']).order(created_at: :asc)

if orders_without_number.empty?
  puts "주문번호가 없는 주문이 없습니다."
  exit
end

puts "총 #{orders_without_number.count}개의 주문에 번호 부여 예정"

# 날짜별로 그룹화하여 처리
orders_by_date = orders_without_number.group_by { |order| order.created_at.strftime('%y%m%d') }

orders_by_date.each do |date_prefix, orders|
  puts "\n#{date_prefix} 날짜: #{orders.count}개 주문 처리 중..."
  
  orders.each_with_index do |order, index|
    sequence = index + 1
    order_number = "#{date_prefix}-#{sequence.to_s.rjust(5, '0')}"
    
    order.update_column(:internal_order_id, order_number)
    puts "  주문 ##{order.id} → #{order_number}"
  end
end

puts "\n완료! 총 #{orders_without_number.count}개 주문에 번호가 부여되었습니다."
