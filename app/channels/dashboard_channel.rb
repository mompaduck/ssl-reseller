class DashboardChannel < ApplicationCable::Channel
  def subscribed
    if admin_user?
      stream_from "dashboard_updates"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def admin_user?
    current_user&.admin? || current_user&.support? || current_user&.super_admin?
  end
end
