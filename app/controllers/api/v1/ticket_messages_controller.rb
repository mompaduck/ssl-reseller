class Api::V1::TicketMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  
  def index
    authorize @ticket, :show?
    @messages = @ticket.messages.includes(:user, :attachments).order(created_at: :asc)
    
    render json: TicketMessageSerializer.new(@messages).serializable_hash
  end
  
  def create
    authorize @ticket, :update?
    
    @message = @ticket.messages.build(message_params)
    @message.user = current_user
    @message.message_type = current_user.support? || current_user.admin? ? :support : :customer
    
    if @message.save
      render json: TicketMessageSerializer.new(@message).serializable_hash, status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end
  
  def message_params
    params.require(:message).permit(:content, attachments_attributes: [:filename, :filesize, :mime_type, :storage_path])
  end
end
