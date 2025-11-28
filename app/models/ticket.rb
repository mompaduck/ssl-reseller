class Ticket < ApplicationRecord
  include AASM
  
  # Associations
  belongs_to :user, optional: true  # Optional for guest tickets
  belongs_to :assigned_to, class_name: 'User', optional: true
  belongs_to :order, optional: true
  belongs_to :certificate, optional: true
  
  has_many :messages, class_name: 'TicketMessage', dependent: :destroy
  has_many :attachments, through: :messages
  
  has_rich_text :content
  
  # Enums
  enum :category, {
    general: 0,
    technical: 1,
    billing: 2,
    validation: 3,
    installation: 4,
    other: 5
  }, default: :other
  
  enum :priority, {
    low: 0,
    normal: 1,
    high: 2,
    urgent: 3
  }, default: :normal
  
  enum :satisfaction_rating, {
    bad: 1,
    neutral: 2,
    good: 3,
    excellent: 4
  }
  
  # Validations
  validates :subject, presence: true
  validates :content, presence: true
  validates :ticket_number, presence: true, uniqueness: true
  
  # Guest ticket validations
  validates :guest_name, presence: true, if: :guest_ticket?
  validates :guest_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :guest_ticket?
  
  # Order-related tickets require authentication
  validate :require_user_for_order_tickets
  
  def guest_ticket?
    user_id.nil?
  end
  
  def requires_authentication?
    [:technical, :billing, :validation, :installation].include?(category.to_sym)
  end
  
  # Scopes
  scope :open, -> { where.not(status: :closed) }
  scope :closed, -> { where(status: :closed) }
  scope :assigned_to_me, ->(user) { where(assigned_to: user) }
  scope :unassigned, -> { where(assigned_to: nil) }
  
  # Callbacks
  before_validation :generate_ticket_number, on: :create
  # after_create :notify_support_team
  after_create :auto_link_resources
  after_create_commit :broadcast_ticket_created
  after_update_commit :broadcast_ticket_status_change, if: :saved_change_to_status?
  
  # State Machine
  aasm column: 'status' do
    state :new, initial: true
    state :open
    state :pending
    state :resolved
    state :closed
    
    event :assign do
      transitions from: [:new, :open], to: :open
    end
    
    event :respond do
      transitions from: [:new, :open, :pending], to: :pending
      after do
        update(first_response_at: Time.current) unless first_response_at.present?
      end
    end
    
    event :customer_reply do
      transitions from: [:pending, :resolved], to: :open
    end
    
    event :resolve do
      transitions from: [:open, :pending], to: :resolved
    end
    
    event :close do
      transitions from: [:new, :open, :pending, :resolved], to: :closed
      after do
        update(closed_at: Time.current)
      end
    end
    
    event :reopen do
      transitions from: [:closed, :resolved], to: :open
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["assigned_to_id", "category", "certificate_id", "closed_at", "created_at", "first_response_at", "id", "order_id", "priority", "satisfaction_rating", "status", "subject", "ticket_number", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assigned_to", "certificate", "messages", "order", "user"]
  end
  
  private
  
  def generate_ticket_number
    return if ticket_number.present?
    
    today = Date.current.strftime('%Y%m%d')
    prefix = "TCK-#{today}-"
    
    # Find the last ticket created today to increment sequence
    last_ticket = Ticket.where("ticket_number LIKE ?", "#{prefix}%").order(ticket_number: :desc).first
    
    if last_ticket
      # Extract sequence number and increment
      last_sequence = last_ticket.ticket_number.split('-').last.to_i
      new_sequence = last_sequence + 1
    else
      # Start with 1 if no tickets today
      new_sequence = 1
    end
    
    self.ticket_number = "#{prefix}#{sprintf('%05d', new_sequence)}"
  end
  
  def auto_link_resources
    # Logic to automatically link order/certificate based on subject/content
    # This is a placeholder for now
  end
  
  def require_user_for_order_tickets
    if guest_ticket? && requires_authentication?
      errors.add(:base, "#{category_name} 문의는 로그인이 필요합니다")
    end
  end
  
  def category_name
    I18n.t("activerecord.attributes.ticket.categories.#{category}", default: category.titleize)
  end
  
  def broadcast_ticket_created
    # Broadcast to admin tickets list
    broadcast_prepend_to(
      "admin_tickets",
      target: "tickets_table_body",
      partial: "admin/tickets/ticket_table_row",
      locals: { ticket: self }
    )
    
    # Update dashboard ticket status card
    broadcast_ticket_status_card
  end
  
  def broadcast_ticket_status_change
    # Update ticket row in admin list
    broadcast_replace_to(
      "admin_tickets",
      target: self,
      partial: "admin/tickets/ticket_table_row",
      locals: { ticket: self }
    )
    
    # Update dashboard ticket status card when status changes
    broadcast_ticket_status_card
  end
  
  def broadcast_ticket_status_card
    # Query ticket data directly
    open_tickets_count = Ticket.where(status: [:new, :open]).count
    pending_tickets_count = Ticket.where(status: :pending).count
    resolved_tickets_count = Ticket.where(status: :resolved).count
    
    # Count both unread messages AND new tickets as notifications
    unread_messages = TicketMessage.where(message_type: :customer, read_at: nil).count
    new_tickets = Ticket.where(status: :new).count
    unread_messages_count = unread_messages + new_tickets
    
    recent_tickets = Ticket.includes(:user)
                           .where(status: [:new, :open])
                           .order(created_at: :desc)
                           .limit(5)
    
    broadcast_replace_to(
      "dashboard_updates",
      target: "ticket_status_card",
      partial: "admin/dashboard/ticket_status_card",
      locals: {
        open_tickets_count: open_tickets_count,
        pending_tickets_count: pending_tickets_count,
        resolved_tickets_count: resolved_tickets_count,
        unread_messages_count: unread_messages_count,
        recent_tickets: recent_tickets
      }
    )
  end
end
