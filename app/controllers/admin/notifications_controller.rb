module Admin
  class NotificationsController < BaseController
    def mark_all_read
      # Update all unread customer messages to read
      TicketMessage.where(message_type: :customer, read_at: nil).update_all(read_at: Time.current)
      
      # Broadcast update to reset counter to 0
      Turbo::StreamsChannel.broadcast_update_to(
        "admin_notifications",
        target: "notification_count",
        html: "0"
      )
      
      head :ok
    end
  end
end
