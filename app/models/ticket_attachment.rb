class TicketAttachment < ApplicationRecord
  belongs_to :ticket_message
  
  enum :virus_scan_status, {
    pending: 0,
    clean: 1,
    infected: 2
  }, default: :pending
  
  validates :filename, presence: true
  validates :filesize, presence: true
  validates :mime_type, presence: true
  validates :storage_path, presence: true
end
