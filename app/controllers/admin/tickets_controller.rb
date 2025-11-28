class Admin::TicketsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_ticket, only: [:show, :assign, :update_status]
  
  # GET /admin/tickets
  def index
    @tickets = Ticket.includes(:user, :assigned_to)
                     .order(created_at: :desc)
    
    # Filter by status
    if params[:status].present?
      @tickets = @tickets.where(status: params[:status])
    end
    
    # Filter by category
    if params[:category].present?
      @tickets = @tickets.where(category: params[:category])
    end
    
    # Filter by assigned
    if params[:assigned].present?
      case params[:assigned]
      when 'me'
        @tickets = @tickets.where(assigned_to: current_user)
      when 'unassigned'
        @tickets = @tickets.where(assigned_to: nil)
      when 'all'
        # Do nothing, show all
      end
    end
    
    # Search
    if params[:q].present?
      @tickets = @tickets.where("subject LIKE ? OR ticket_number LIKE ? OR guest_email LIKE ?", 
                                "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    
    @tickets = @tickets.page(params[:page]).per(20)
  end
  
  # GET /admin/tickets/:id
  def show
    # Auto-mark ticket as read by transitioning from 'new' to 'open' state
    if @ticket.status == 'new' && @ticket.may_assign?
      @ticket.assign!
    end
    
    @messages = @ticket.messages.includes(:user).order(:created_at)
  end
  
  # PATCH /admin/tickets/:id/assign
  def assign
    if @ticket.update(assigned_to_id: params[:assigned_to_id])
      @ticket.assign! if @ticket.may_assign?
      redirect_to admin_ticket_path(@ticket), notice: "티켓이 할당되었습니다."
    else
      redirect_to admin_ticket_path(@ticket), alert: "티켓 할당에 실패했습니다."
    end
  end
  
  # PATCH /admin/tickets/:id/update_status
  def update_status
    new_status = params[:status]
    
    case new_status
    when 'resolved'
      if @ticket.may_resolve?
        @ticket.resolve!
        redirect_to admin_ticket_path(@ticket), notice: "티켓이 해결됨으로 변경되었습니다."
      else
        redirect_to admin_ticket_path(@ticket), alert: "티켓 상태를 변경할 수 없습니다."
      end
    when 'closed'
      if @ticket.may_close?
        @ticket.close!
        redirect_to admin_ticket_path(@ticket), notice: "티켓이 종료되었습니다."
      else
        redirect_to admin_ticket_path(@ticket), alert: "티켓을 종료할 수 없습니다."
      end
    when 'reopen'
      if @ticket.may_reopen?
        @ticket.reopen!
        redirect_to admin_ticket_path(@ticket), notice: "티켓이 다시 열렸습니다."
      else
        redirect_to admin_ticket_path(@ticket), alert: "티켓을 다시 열 수 없습니다."
      end
    else
      redirect_to admin_ticket_path(@ticket), alert: "알 수 없는 상태입니다."
    end
  end
  
  private
  
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end
  
  def require_admin!
    unless current_user.can_access_admin?
      redirect_to root_path, alert: "접근 권한이 없습니다."
    end
  end
end
