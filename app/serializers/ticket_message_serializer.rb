class TicketMessageSerializer
  include JSONAPI::Serializer
  
  attributes :id, :message_type, :content, :created_at, :is_read
  
  attribute :user_name do |object|
    object.user.name
  end
  
  attribute :attachments do |object|
    object.attachments.map do |attachment|
      {
        id: attachment.id,
        filename: attachment.filename,
        filesize: attachment.filesize,
        url: attachment.storage_path # Or generate signed URL
      }
    end
  end
end
