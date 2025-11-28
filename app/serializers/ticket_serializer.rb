class TicketSerializer
  include JSONAPI::Serializer
  
  attributes :id, :ticket_number, :subject, :status, :priority, :category, :created_at, :updated_at, :closed_at
  
  attribute :user_name do |object|
    object.user&.name || object.guest_name
  end
  
  attribute :assigned_to_name do |object|
    object.assigned_to&.name
  end
  
  attribute :last_message_at do |object|
    object.messages.last&.created_at
  end
  
  attribute :is_read_by_user do |object, params|
    # Logic to determine if the ticket has unread messages for the current user
    # This might need optimization
    if params[:current_user]
      !object.messages.where.not(user_id: params[:current_user].id).where(is_read: false).exists?
    else
      true
    end
  end
end
