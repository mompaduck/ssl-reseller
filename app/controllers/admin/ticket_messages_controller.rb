class Admin::TicketMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_message, only: [:mark_as_read]
  
  def mark_as_read
    if @message.update(read_at: Time.current)
      render json: { success: true, read_at: @message.read_at }
    else
      render json: { success: false, errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def mark_all_read
    TicketMessage.where(message_type: :customer, read_at: nil).update_all(read_at: Time.current)
    
    # Broadcast counter update
    broadcast_update_to(
      "admin_notifications",
      target: "notification_count",
      html: "0"
    )
    
    head :ok
  end
  
  private
  
  def set_message
    @message = TicketMessage.find(params[:id])
  end
  
  def authorize_admin
    unless current_user.admin? || current_user.support? || current_user.super_admin?
      redirect_to root_path, alert: "권한이 없습니다."
    end
  end
end
