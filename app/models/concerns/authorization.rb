module Authorization
  extend ActiveSupport::Concern

  def can_manage_users?
    super_admin? || admin?
  end

  def can_edit_orders?
    super_admin? || admin?
  end

  def can_edit_certificates?
    super_admin? || admin?
  end

  def can_view_all_orders?
    super_admin? || admin? || support?
  end

  def can_access_admin?
    super_admin? || admin? || support? || partner?
  end

  def accessible_users
    if super_admin? || admin? || support?
      User.all
    elsif partner?
      assigned_users
    else
      User.where(id: id)
    end
  end

  def accessible_orders
    if super_admin? || admin? || support?
      Order.all
    elsif partner?
      Order.where(user_id: assigned_users.pluck(:id))
    else
      orders
    end
  end

  def accessible_certificates
    if super_admin? || admin? || support?
      Certificate.all
    elsif partner?
      Certificate.where(user_id: assigned_users.pluck(:id))
    else
      certificates
    end
  end
end
