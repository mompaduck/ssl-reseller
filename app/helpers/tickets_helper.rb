module TicketsHelper
  # Status badge classes
  def ticket_status_class(status)
    case status.to_s
    when 'new'
      'bg-blue-100 text-blue-800'
    when 'open'
      'bg-indigo-100 text-indigo-800'
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'resolved'
      'bg-green-100 text-green-800'
    when 'closed'
      'bg-gray-100 text-gray-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  # Status text
  def ticket_status_text(status)
    case status.to_s
    when 'new'
      '신규'
    when 'open'
      '진행중'
    when 'pending'
      '대기중'
    when 'resolved'
      '해결됨'
    when 'closed'
      '종료'
    else
      status.to_s.humanize
    end
  end

  # Category text
  def ticket_category_text(category)
    case category.to_s
    when 'general'
      '일반 문의'
    when 'technical'
      '기술 지원'
    when 'billing'
      '결제/환불'
    when 'validation'
      '인증 문제'
    when 'installation'
      '설치 지원'
    when 'other'
      '기타'
    else
      category.to_s.humanize
    end
  end

  # Priority badge classes
  def ticket_priority_class(priority)
    case priority.to_s
    when 'low'
      'bg-gray-100 text-gray-700'
    when 'normal'
      'bg-blue-100 text-blue-700'
    when 'high'
      'bg-orange-100 text-orange-700'
    when 'urgent'
      'bg-red-100 text-red-700'
    else
      'bg-gray-100 text-gray-700'
    end
  end

  # Priority text
  def ticket_priority_text(priority)
    case priority.to_s
    when 'low'
      '낮음'
    when 'normal'
      '보통'
    when 'high'
      '높음'
    when 'urgent'
      '긴급'
    else
      priority.to_s.humanize
    end
  end
end
