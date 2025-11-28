class TicketTemplate < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  
  enum :category, {
    order_payment: 0,
    certificate_issuance: 1,
    installation_setup: 2,
    refund: 3,
    technical: 4,
    general: 5
  }
  
  validates :name, presence: true
  validates :content, presence: true
  validates :category, presence: true
end
