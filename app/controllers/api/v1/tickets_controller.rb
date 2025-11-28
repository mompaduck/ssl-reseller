class Api::V1::TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_ticket, only: [:show, :update, :close]
  before_action :authenticate_user!, except: [:create]  # Allow guest ticket creation
  before_action :authorize_ticket, only: [:show, :update, :close]
  
  def index
    @tickets = policy_scope(Ticket).includes(:user, :assigned_to, :order, :certificate)
    
    if params[:status].present?
      @tickets = @tickets.where(status: params[:status])
    end
    
    @tickets = @tickets.order(created_at: :desc).page(params[:page]).per(20)
    
    render json: TicketSerializer.new(@tickets, { params: { current_user: current_user } }).serializable_hash
  end
  
  def show
    render json: TicketSerializer.new(@ticket, { include: [:messages], params: { current_user: current_user } }).serializable_hash
  end
  
  def create
    @ticket = Ticket.new(ticket_params)
    
    # Set user if authenticated, otherwise it's a guest ticket
    @ticket.user = current_user if user_signed_in?
    
    # Authorize based on whether it's a guest or authenticated ticket
    if user_signed_in?
      authorize @ticket
    else
      # Guest tickets: only allow general/other categories
      if @ticket.requires_authentication?
        return render json: { 
          errors: ["#{@ticket.category} 카테고리는 로그인이 필요합니다. 로그인 후 다시 시도해주세요."] 
        }, status: :unauthorized
      end
    end
    
    if @ticket.save
      render json: TicketSerializer.new(@ticket).serializable_hash, status: :created
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    @ticket = Ticket.find(params[:id])
    authorize @ticket
    
    if @ticket.update(ticket_params)
      render json: TicketSerializer.new(@ticket).serializable_hash
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def close
    @ticket = Ticket.find(params[:id])
    authorize @ticket
    
    if @ticket.close!
      render json: TicketSerializer.new(@ticket).serializable_hash
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def ticket_params
    params.require(:ticket).permit(
      :subject, :content, :category, :priority, 
      :order_id, :certificate_id,
      :guest_name, :guest_email, :guest_phone  # Guest fields
    )
  end
end
