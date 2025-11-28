class TicketPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    owner? || support_team? || partner_customer?
  end
  
  def create?
    user.present?
  end
  
  def update?
    owner? || support_team?
  end
  
  def destroy?
    user.super_admin?
  end
  
  def close?
    owner? || support_team?
  end
  
  def assign?
    support_team?
  end
  
  def view_internal_notes?
    support_team?
  end
  
  def manage_templates?
    user.admin? || user.super_admin?
  end
  
  private
  
  def owner?
    record.user_id == user.id
  end
  
  def support_team?
    user.support? || user.admin? || user.super_admin?
  end
  
  def partner_customer?
    user.partner? && record.user.assigned_partner_id == user.id
  end
  
  class Scope < Scope
    def resolve
      case user.role
      when 'user'
        scope.where(user_id: user.id)
      when 'partner'
        # Assuming partner has many customers via assigned_partner_id
        scope.where(user_id: User.where(assigned_partner_id: user.id).pluck(:id))
      when 'support', 'admin', 'super_admin'
        scope.all
      else
        scope.none
      end
    end
  end
end
