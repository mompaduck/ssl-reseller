module Admin
  class BaseController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :require_admin

    private

    def require_admin
      unless current_user.can_access_admin?
        redirect_to root_path, alert: '접근 권한이 없습니다.'
      end
    end
  end
end
