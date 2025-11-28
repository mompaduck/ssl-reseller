class TicketMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  before_action :authorize_ticket_access
  
  # POST /tickets/:ticket_id/messages
  def create
    @message = @ticket.messages.build(message_params)
    @message.user = current_user
    
    # Set message type based on user role
    if current_user.admin? || current_user.super_admin? || current_user.support?
      @message.message_type = :support
    else
      @message.message_type = :customer
    end
    
    if @message.save
      # Trigger ticket state transition if needed
      is_staff = current_user.admin? || current_user.super_admin? || current_user.support?
      
      if is_staff
        # Auto-assign if unassigned
        if @ticket.assigned_to_id.nil?
          @ticket.update(assigned_to: current_user)
        end

        if params[:close_ticket] == '1'
          @ticket.close! if @ticket.may_close?
        else
          @ticket.respond! if @ticket.may_respond?
        end
        
        # Send email notification to customer
        begin
          TicketMailer.new_reply_notification(@ticket, @message).deliver_later
        rescue => e
          Rails.logger.error("Failed to send ticket reply email: #{e.message}")
        end
      else
        @ticket.customer_reply! if @ticket.may_customer_reply?
      end
      
      # Redirect to appropriate path based on referrer
      if request.referer&.include?('/admin/')
        redirect_to admin_ticket_path(@ticket), notice: "답변이 등록되었습니다."
      else
        redirect_to ticket_path(@ticket), notice: "답변이 등록되었습니다."
      end
    else
      if request.referer&.include?('/admin/')
        redirect_to admin_ticket_path(@ticket), alert: "답변 등록 중 오류가 발생했습니다: #{@message.errors.full_messages.join(', ')}"
      else
        redirect_to ticket_path(@ticket), alert: "답변 등록 중 오류가 발생했습니다: #{@message.errors.full_messages.join(', ')}"
      end
    end
  end
  
  private
  
  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end
  
  def authorize_ticket_access
    # Allow access if user owns the ticket or is admin/support
    is_staff = current_user.admin? || current_user.super_admin? || current_user.support?
    is_ticket_owner = @ticket.user_id && @ticket.user_id == current_user.id
    
    unless is_ticket_owner || is_staff
      redirect_to root_path, alert: "해당 티켓에 접근할 수 없습니다."
    end
  end
  
  def message_params
    params.require(:ticket_message).permit(:content) rescue params.permit(:content)
  end
end
