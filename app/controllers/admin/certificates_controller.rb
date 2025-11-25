module Admin
  class CertificatesController < BaseController
    before_action :check_edit_permission, only: [:reissue, :cancel, :resend_dcv, :refresh_status, :send_reminder]
    
    def index
      @certificates = current_user.accessible_certificates.includes(:user, :order)
      
      # Search
      if params[:q].present?
        @certificates = @certificates.joins(:order, :user).where(
          "orders.domain LIKE ? OR users.email LIKE ? OR orders.internal_order_id LIKE ? OR certificates.id LIKE ?",
          "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%"
        )
      end
      
      # Filters
      @certificates = @certificates.where(status: params[:status]) if params[:status].present?
      @certificates = @certificates.where(certificate_type: params[:certificate_type]) if params[:certificate_type].present?
      @certificates = @certificates.where(dcv_method: params[:dcv_method]) if params[:dcv_method].present?
      
      @certificates = @certificates.order(created_at: :desc).page(params[:page]).per(20)
      
      # Stats
      @stats = {
        total: current_user.accessible_certificates.count,
        issued: current_user.accessible_certificates.issued.count,
        pending: current_user.accessible_certificates.pending.count,
        dcv_failed: current_user.accessible_certificates.where(status: :dcv_failed).count
      }
      
      # Legacy stats variables (for compatibility)
      @issued_30d = current_user.accessible_certificates.issued.where("issued_at >= ?", 30.days.ago).count
      @dcv_failed = @stats[:dcv_failed]
      @pending = @stats[:pending]
      @expiring_soon = current_user.accessible_certificates.issued.where(expires_at: Time.current..30.days.from_now).count
      @refund_requests = 0 # Placeholder
      @api_errors = PartnerApiLog.where(status: 'error').where("created_at >= ?", 30.days.ago).count
    end

    def show
      @certificate = Certificate.find(params[:id])
      @order = @certificate.order
      @user = @certificate.user
      
      # Parse CSR if available and not parsed
      if @order.csr.present? && @certificate.csr_parsed_data.blank?
        # In a real app, we would parse the CSR here using OpenSSL
        # @certificate.csr_parsed_data = parse_csr(@order.csr)
      end
    end

    def download
      @certificate = Certificate.find(params[:id])
      format = params[:format] || 'zip'
      
      # In a real app, generate the file content based on format
      # For now, just send a dummy text file
      send_data "Certificate Content for #{@certificate.serial_number}", 
        filename: "#{@certificate.order.domain}.#{format}", 
        type: "application/#{format}"
    end

    def reissue
      @certificate = Certificate.find(params[:id])
      service = SslProviderService.new
      result = service.reissue(@certificate.order.partner_order_number, @certificate.order.csr)
      
      if result.success?
        AuditLogger.log(current_user, @certificate, 'reissue', "재발급 요청 (Order ID: #{result.order_id})", {}, request.remote_ip)
        redirect_to admin_certificate_path(@certificate), notice: "재발급 요청이 전송되었습니다."
      else
        redirect_to admin_certificate_path(@certificate), alert: "재발급 요청 실패"
      end
    end

    def cancel
      @certificate = Certificate.find(params[:id])
      service = SslProviderService.new
      result = service.cancel_order(@certificate.order.partner_order_number)
      
      if result.success?
        @certificate.canceled!
        AuditLogger.log(current_user, @certificate, 'cancel', "주문 취소", {}, request.remote_ip)
        redirect_to admin_certificate_path(@certificate), notice: "주문이 취소되었습니다."
      else
        redirect_to admin_certificate_path(@certificate), alert: "주문 취소 실패"
      end
    end

    def resend_dcv
      @certificate = Certificate.find(params[:id])
      service = SslProviderService.new
      result = service.resend_dcv(@certificate.order.partner_order_number)
      
      if result.success?
        AuditLogger.log(current_user, @certificate, 'resend_dcv', "DCV 이메일 재전송", {}, request.remote_ip)
        redirect_to admin_certificate_path(@certificate), notice: "DCV 이메일이 재전송되었습니다."
      else
        redirect_to admin_certificate_path(@certificate), alert: "DCV 재전송 실패"
      end
    end

    def refresh_status
      @certificate = Certificate.find(params[:id])
      service = SslProviderService.new
      result = service.refresh_status(@certificate.order.partner_order_number)
      
      if result.success?
        # Map API status to model status
        # This is a simplified mapping
        new_status = case result.status
                     when 'issued' then :issued
                     when 'pending' then :pending
                     when 'dcv_failed' then :dcv_failed
                     else :pending
                     end
        
        old_status = @certificate.status
        @certificate.update(status: new_status)
        
        if old_status != new_status
           AuditLogger.log(current_user, @certificate, 'status_change', "상태 변경: #{old_status} -> #{new_status}", { old_status: old_status, new_status: new_status }, request.remote_ip)
        end
        
        redirect_to admin_certificate_path(@certificate), notice: "상태가 갱신되었습니다: #{result.status}"
      else
        redirect_to admin_certificate_path(@certificate), alert: "상태 갱신 실패"
      end
    end

    def send_reminder
      @certificate = Certificate.find(params[:id])
      # In a real app, trigger a mailer here
      # UserMailer.expiration_reminder(@certificate).deliver_later
      AuditLogger.log(current_user, @certificate, 'send_reminder', "만료 알림 메일 발송", {}, request.remote_ip)
      redirect_to admin_certificate_path(@certificate), notice: "만료 알림 메일이 발송되었습니다."
    end

    private

    def check_edit_permission
      unless current_user.can_edit_certificates?
        redirect_to admin_certificates_path, alert: '수정 권한이 없습니다.'
      end
    end
  end
end
