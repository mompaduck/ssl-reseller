class TicketMessage < ApplicationRecord
  belongs_to :ticket
  belongs_to :user
  
  has_many :attachments, class_name: 'TicketAttachment', dependent: :destroy
  has_rich_text :content
  
  enum :message_type, {
    customer: 0,
    support: 1,
    internal_note: 2
  }
  
  validates :content, presence: true
  validates :message_type, presence: true
  
  
  # Real-time broadcast
  after_create_commit :broadcast_new_message
  after_create_commit :broadcast_to_admin, if: :customer?
  after_create_commit :mark_ticket_activity
  after_create_commit :trigger_state_transition
  after_update_commit :broadcast_read_status, if: :saved_change_to_read_at?

  
  private
  
  
  def broadcast_new_message
    # Broadcast to specific ticket stream for viewers
    broadcast_append_to(
      "ticket_#{ticket.id}_messages",
      target: "messages",
      partial: "ticket_messages/message",
      locals: { message: self }
    )
  end
  
  def broadcast_to_admin
    # Broadcast to admin notification stream
    broadcast_prepend_to(
      "admin_notifications",
      target: "admin_notifications",
      partial: "admin/notifications/message_notification",
      locals: { message: self }
    )
    
    # Update notification counter badge by replacing the entire element
    count = unread_admin_messages_count
    count_text = count > 99 ? "99+" : count.to_s
    
    # Determine badge HTML based on count
    badge_html = if count > 0
      <<~HTML
        <span id="notification_badge" 
              data-notification-target="badge"
              class="absolute top-0 right-0 inline-flex items-center justify-center px-1.5 py-0.5 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-600 rounded-full">
          <span id="notification_count" data-notification-target="count">#{count_text}</span>
        </span>
      HTML
    else
      <<~HTML
        <span id="notification_badge" 
              data-notification-target="badge"
              class="absolute top-0 right-0 inline-flex items-center justify-center px-1.5 py-0.5 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-600 rounded-full hidden">
          <span id="notification_count" data-notification-target="count">0</span>
        </span>
      HTML
    end

    broadcast_replace_to(
      "admin_notifications",
      target: "notification_badge",
      html: badge_html
    )
    
    # Update dashboard ticket status card (new message activity)
    broadcast_ticket_status_card
  end
  
  def broadcast_read_status
    # Broadcast read status change to ticket viewers
    broadcast_replace_to(
      "ticket_#{ticket.id}_messages",
      target: "message_#{id}",
      partial: "ticket_messages/message",
      locals: { message: self }
    )
  end
  
  def unread_admin_messages_count
    TicketMessage.where(message_type: :customer, read_at: nil).count
  end

  
  def mark_ticket_activity
    ticket.touch
  end
  
  def trigger_state_transition
    if support? && ticket.open?
      ticket.respond!
    elsif customer? && ticket.pending?
      ticket.customer_reply!
    end
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
