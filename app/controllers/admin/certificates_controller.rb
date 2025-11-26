module Admin
  class CertificatesController < BaseController
    before_action :check_edit_permission, only: [:reissue, :cancel, :resend_dcv, :refresh_status, :send_reminder, :refresh_dcv, :change_dcv_method, :force_issue]
    
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

    # Tab actions for Turbo Frames
    def overview
      set_certificate_data
      render partial: 'overview', layout: false
    end

    def dcv
      set_certificate_data
      render partial: 'dcv', layout: false
    end

    def files
      set_certificate_data
      render partial: 'files', layout: false
    end

    def issue_logs
      set_certificate_data
      render partial: 'issue_logs', layout: false
    end

    def audit_logs
      set_certificate_data
      render partial: 'audit_logs', layout: false
    end

    def billing
      set_certificate_data
      render partial: 'billing', layout: false
    end

    def customer
      set_certificate_data
      render partial: 'customer', layout: false
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
        CertificateLog.create!(certificate: @certificate, user: current_user, action: 'reissued', message: "재발급 요청 (Order ID: #{result.order_id})", metadata: {}, ip_address: request.remote_ip)
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
        CertificateLog.create!(certificate: @certificate, user: current_user, action: 'cancelled', message: "주문 취소", metadata: {}, ip_address: request.remote_ip)
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
        CertificateLog.create!(certificate: @certificate, user: current_user, action: 'dcv_sent', message: "DCV 이메일 재전송", metadata: {}, ip_address: request.remote_ip)
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
           CertificateLog.create!(certificate: @certificate, user: current_user, action: 'status_changed', message: "상태 변경: #{old_status} -> #{new_status}", metadata: { old_status: old_status, new_status: new_status }, ip_address: request.remote_ip)
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
      CertificateLog.create!(certificate: @certificate, user: current_user, action: 'expiring_soon', message: "만료 알림 메일 발송", metadata: {}, ip_address: request.remote_ip)
      redirect_to admin_certificate_path(@certificate), notice: "만료 알림 메일이 발송되었습니다."
    end

    def refresh_dcv
      @certificate = Certificate.find(params[:id])
      service = SslProviderService.new
      result = service.check_dcv_status(@certificate.order.partner_order_number)
      
      if result.success?
        CertificateLog.create!(certificate: @certificate, user: current_user, action: 'dcv_completed', message: "DCV 상태 새로고침", metadata: {}, ip_address: request.remote_ip)
        redirect_to admin_certificate_path(@certificate), notice: "DCV 상태가 갱신되었습니다."
      else
        redirect_to admin_certificate_path(@certificate), alert: "DCV 상태 갱신 실패"
      end
    end

    def change_dcv_method
      @certificate = Certificate.find(params[:id])
      new_method = params[:new_method]
      
      # Validate state - only allow changes in pending or dcv_failed status
      unless ['pending', 'dcv_failed'].include?(@certificate.status)
        redirect_to admin_certificate_path(@certificate), 
          alert: "DCV 방식 변경은 pending 또는 dcv_failed 상태에서만 가능합니다. (현재: #{@certificate.status})"
        return
      end
      
      # Validate method
      valid_methods = ['EMAIL', 'HTTP', 'HTTPS', 'DNS', 'CNAME']
      unless valid_methods.include?(new_method&.upcase)
        redirect_to admin_certificate_path(@certificate), 
          alert: "유효하지 않은 DCV 방식입니다."
        return
      end
      
      # Reset DCV data
      @certificate.update(
        dcv_method: new_method.upcase,
        dcv_email: nil,
        dcv_cname_host: nil,
        dcv_cname_value: nil,
        dcv_file_content: nil,
        dcv_file_url: nil
      )
      
      # Call API and generate new DCV data
      service = SslProviderService.new
      result = service.change_dcv_method(@certificate.order.partner_order_number, new_method)
      
      if result.success?
        # Update certificate with new DCV data based on method
        case new_method.upcase
        when 'EMAIL'
          @certificate.update(dcv_email: result.dcv_email || "admin@#{@certificate.order.domain}")
        when 'HTTP', 'HTTPS'
          @certificate.update(
            dcv_file_content: result.file_content,
            dcv_file_url: result.file_url
          )
        when 'DNS', 'CNAME'
          @certificate.update(
            dcv_cname_host: result.cname_host,
            dcv_cname_value: result.cname_value
          )
        end
        
        CertificateLog.create!(certificate: @certificate, user: current_user, action: 'dcv_sent',
                      message: "DCV 방식 변경: #{old_method} -> #{new_method}",
                      metadata: { old_method: old_method, new_method: new_method }, ip_address: request.remote_ip)
        
        redirect_to admin_certificate_path(@certificate), 
          notice: "DCV 방식이 #{new_method}(으)로 변경되었습니다."
      else
        redirect_to admin_certificate_path(@certificate), 
          alert: "DCV 방식 변경 실패: #{result.error}"
      end
    end

    def download_dcv_file
      @certificate = Certificate.find(params[:id])
      
      # Generate DCV file content
      file_content = @certificate.dcv_file_content || "DCV-VALIDATION-CONTENT-HERE\nSectigo-DCV-#{@certificate.id}"
      
      send_data file_content,
        filename: "fileauth.txt",
        type: "text/plain",
        disposition: "attachment"
      
      CertificateLog.create!(certificate: @certificate, user: current_user, action: 'downloaded', message: "DCV 파일 다운로드", metadata: {}, ip_address: request.remote_ip)
    end

    def force_issue
      @certificate = Certificate.find(params[:id])
      service = SslProviderService.new
      
      # This is a rare case action - force issue the certificate
      # In a real app, this would call a special Sectigo API endpoint
      result = service.force_issue(@certificate.order.partner_order_number)
      
      if result.success?
        @certificate.update(status: :issued, issued_at: Time.current)
        CertificateLog.create!(certificate: @certificate, user: current_user, action: 'issued', message: "강제 발급 요청 (관리자: #{current_user.name})", metadata: { reason: 'manual_override' }, ip_address: request.remote_ip)
        redirect_to admin_certificate_path(@certificate), notice: "강제 발급 요청이 처리되었습니다."
      else
        redirect_to admin_certificate_path(@certificate), alert: "강제 발급 요청 실패"
      end
    end

    private

    def set_certificate_data
      @certificate = Certificate.find(params[:id])
      @order = @certificate.order
      @user = @certificate.user
    end

    def check_edit_permission
      unless current_user.can_edit_certificates?
        redirect_to admin_certificates_path, alert: '수정 권한이 없습니다.'
      end
    end
  end
end
