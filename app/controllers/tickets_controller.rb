class TicketsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  before_action :set_ticket, only: [:show, :close]
  before_action :authorize_ticket_access, only: [:show]
  
  # GET /tickets
  def index
    @tickets = current_user.tickets
                          .includes(:user, :assigned_to)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(20)
  end
  
  # GET /tickets/new
  def new
    @ticket = Ticket.new(
      subject: params[:subject],
      category: params[:category]
    )
  end
  
  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)
    
    # Set user if authenticated
    @ticket.user = current_user if user_signed_in?
    
    # Validate authentication requirements
    if @ticket.guest_ticket? && @ticket.requires_authentication?
      @ticket.errors.add(:base, "#{ticket_category_text(@ticket.category)} 카테고리는 로그인이 필요합니다.")
      flash.now[:alert] = "로그인이 필요한 카테고리입니다."
      render :new, status: :unprocessable_entity
      return
    end
    
    if @ticket.save
      if user_signed_in?
        redirect_to tickets_path, notice: "문의가 성공적으로 접수되었습니다. (티켓 번호: #{@ticket.ticket_number})"
      else
        redirect_to root_path, notice: "문의가 접수되었습니다. 등록하신 이메일로 답변을 보내드리겠습니다. (티켓 번호: #{@ticket.ticket_number})"
      end
    else
      flash.now[:alert] = "문의 접수 중 오류가 발생했습니다."
      render :new, status: :unprocessable_entity
    end
  end
  
  # GET /tickets/:id
  def show
    @ticket = Ticket.includes(messages: :user).find(params[:id])
    authorize_ticket_access
  end
  
  # PATCH /tickets/:id/close
  def close
    authorize_ticket_access
    
    if @ticket.close!
      redirect_to ticket_path(@ticket), notice: "티켓이 종료되었습니다."
    else
      redirect_to ticket_path(@ticket), alert: "티켓 종료 중 오류가 발생했습니다."
    end
  end
  
  private
  
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end
  
  def authorize_ticket_access
    # Allow access if user owns the ticket or is admin
    unless @ticket.user_id == current_user&.id || current_user&.admin?
      redirect_to root_path, alert: "해당 티켓에 접근할 수 없습니다."
    end
  end
  
  def ticket_params
    params.require(:ticket).permit(
      :subject, :content, :category, :priority,
      :guest_name, :guest_email, :guest_phone
    )
  end
end

