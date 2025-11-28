class TicketChannel < ApplicationCable::Channel
  def subscribed
    ticket = Ticket.find(params[:id])
    if current_user_can_access?(ticket)
      stream_for ticket
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  private
  
  def current_user_can_access?(ticket)
    # Re-use policy logic or simple check
    return true if current_user.admin? || current_user.support? || current_user.super_admin?
    ticket.user_id == current_user.id
  end
end
