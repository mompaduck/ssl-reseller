module Admin
  class UsersController < BaseController
    before_action :require_user_management_permission, except: [:index, :show]
    
    def index
      @users = current_user.accessible_users.includes(:orders)
      
      # Search
      if params[:q].present?
        query = "%#{params[:q]}%"
        @users = @users.where(
          "users.name LIKE ? OR users.email LIKE ? OR users.company_name LIKE ?",
          query, query, query
        )
      end
      
      # Role Filter
      @users = @users.where(role: params[:role]) if params[:role].present?
      
      # Status Filter
      @users = @users.where(status: params[:status]) if params[:status].present?
      
      # Sorting
      @users = case params[:sort]
               when 'id_asc' then @users.order(id: :asc)
               when 'id_desc' then @users.order(id: :desc)
               when 'name_asc' then @users.order(Arel.sql('LOWER(name) ASC'))
               when 'name_desc' then @users.order(Arel.sql('LOWER(name) DESC'))
               when 'email_asc' then @users.order(Arel.sql('LOWER(email) ASC'))
               when 'email_desc' then @users.order(Arel.sql('LOWER(email) DESC'))
               when 'created_asc' then @users.order(created_at: :asc)
               when 'created_desc' then @users.order(created_at: :desc)
               when 'last_sign_in_asc' then @users.order(Arel.sql('CASE WHEN current_sign_in_at IS NULL THEN 1 ELSE 0 END, current_sign_in_at ASC'))
               when 'last_sign_in_desc' then @users.order(Arel.sql('CASE WHEN current_sign_in_at IS NULL THEN 1 ELSE 0 END, current_sign_in_at DESC'))
               when 'status_asc' then @users.order(status: :asc)
               when 'status_desc' then @users.order(status: :desc)
               when 'role_asc' then @users.order(role: :asc)
               when 'role_desc' then @users.order(role: :desc)
               else @users.order(created_at: :desc)
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
