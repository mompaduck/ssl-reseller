class Api::V1::Admin::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_support
  
  def index
    @tickets = Ticket.includes(:user, :assigned_to).all
    
    if params[:status].present?
      @tickets = @tickets.where(status: params[:status])
    end
    
    if params[:assigned_to_me] == 'true'
      @tickets = @tickets.where(assigned_to: current_user)
    end
    
    @tickets = @tickets.order(created_at: :desc).page(params[:page]).per(20)
    
    render json: TicketSerializer.new(@tickets).serializable_hash
  end
  
  def assign
    @ticket = Ticket.find(params[:id])
    authorize @ticket, :assign?
    
    if @ticket.update(assigned_to_id: params[:assigned_to_id])
      @ticket.assign! if @ticket.new?
      render json: TicketSerializer.new(@ticket).serializable_hash
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def ensure_admin_or_support
    unless current_user.admin? || current_user.support? || current_user.super_admin?
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end
end
