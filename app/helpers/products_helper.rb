module ProductsHelper
  # 가격을 3자리 콤마로 포맷 (₩ 표시 포함)
  def format_price(price)
    number_to_currency(price, unit: "₩", precision: 0, delimiter: ",")
  end

  # 기간(개월 수)을 "1년 / 2년" 형태로 변환
  def format_duration(months)
    return "#{months / 12}년" if months % 12 == 0
    "#{months}개월"
  end

  # 공급사 이름에 따른 배지 색상
  def provider_badge(provider)
    color = case provider.downcase
            when "sectigo" then "bg-green-600"
            when "digicert" then "bg-blue-600"
            when "globalsign" then "bg-indigo-600"
            else "bg-gray-600"
            end

    content_tag(:span, provider.capitalize, class: "px-2 py-1 text-xs font-semibold text-white rounded #{color}")
  end

  # 상품 상태 표시 (활성/비활성)
  def product_status_badge(is_active)
    if is_active
      content_tag(:span, "판매중", class: "bg-green-500 text-white px-2 py-1 text-xs rounded")
    else
      content_tag(:span, "일시중지", class: "bg-gray-500 text-white px-2 py-1 text-xs rounded")
    end
  end
end