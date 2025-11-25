module Admin
  class UsersController < BaseController
    before_action :require_user_management_permission, except: [:index, :show]
    
    def index
      @users = User.all

      # Search
      if params[:q].present?
        query = "%#{params[:q]}%"
        @users = @users.where("email LIKE ? OR name LIKE ? OR phone LIKE ?", query, query, query)
      end

      # Filters
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where(status: params[:status]) if params[:status].present?

      # Sorting
      case params[:sort]
      when 'created_at_asc'
        @users = @users.order(created_at: :asc)
      when 'created_at_desc'
        @users = @users.order(created_at: :desc)
      when 'last_sign_in_asc'
        @users = @users.order(current_sign_in_at: :asc)
      when 'last_sign_in_desc'
        @users = @users.order(current_sign_in_at: :desc)
      when 'orders_count'
        @users = @users.left_joins(:orders).group('users.id').order('COUNT(orders.id) DESC')
      else
        @users = @users.order(created_at: :desc)
      end

      @users = @users.page(params[:page]).per(20)
    end

    def show
      @user = User.find(params[:id])
      @orders = @user.orders.order(created_at: :desc).limit(10)
      @certificates = @user.certificates.order(created_at: :desc).limit(10)
    end

    def update_role
      @user = User.find(params[:id])
      
      if @user.update(role: params[:user][:role])
        AuditLogger.log(current_user, @user, 'role_change', "역할 변경: #{@user.role}", { role: @user.role }, request.remote_ip)
        redirect_to admin_user_path(@user), notice: "역할이 변경되었습니다."
      else
        redirect_to admin_user_path(@user), alert: "역할 변경 실패"
      end
    end

    def assign_partner
      @user = User.find(params[:id])
      
      if @user.update(assigned_partner_id: params[:user][:assigned_partner_id])
        partner_name = @user.assigned_partner&.name || "없음"
        AuditLogger.log(current_user, @user, 'partner_assignment', "파트너 할당: #{partner_name}", { partner_id: @user.assigned_partner_id }, request.remote_ip)
        redirect_to admin_user_path(@user), notice: "파트너가 할당되었습니다."
      else
        redirect_to admin_user_path(@user), alert: "파트너 할당 실패"
      end
    end

    private

    def require_user_management_permission
      unless current_user.can_manage_users?
        redirect_to admin_root_path, alert: '사용자 관리 권한이 없습니다.'
      end
    end
  end
end
