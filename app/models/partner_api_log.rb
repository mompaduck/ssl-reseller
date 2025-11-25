class PartnerApiLog < ApplicationRecord
  belongs_to :order

  scope :recent, -> { order(created_at: :desc) }
  
  def badge_color
    case status&.downcase
    when 'success', 'completed'
      'bg-green-100 text-green-800'
    when 'pending', 'processing'
      'bg-yellow-100 text-yellow-800'
    when 'failed', 'error'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
