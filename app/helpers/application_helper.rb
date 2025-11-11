module ApplicationHelper
  def toast_details(type)
    case type.to_s
    when 'notice'
      {
        bg_class: 'bg-green-500',
        hover_bg_class: 'hover:bg-green-600',
        icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
      }
    when 'alert'
      {
        bg_class: 'bg-red-500',
        hover_bg_class: 'hover:bg-red-600',
        icon: 'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z'
      }
    else
      {
        bg_class: 'bg-gray-500',
        hover_bg_class: 'hover:bg-gray-600',
        icon: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
      }
    end
  end
end
