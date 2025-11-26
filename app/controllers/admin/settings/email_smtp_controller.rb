module Admin
  module Settings
    class EmailSmtpController < Admin::BaseController
      def email_smtp
        # Load current SMTP settings
        @smtp_host = Setting.get_string('smtp_host', 'smtp.gmail.com')
        @smtp_port = Setting.get('smtp_port', 587)
        @smtp_username = Setting.get_string('smtp_username', '')
        @smtp_password = Setting.get_string('smtp_password', '')
        @smtp_from_email = Setting.get_string('smtp_from_email', 'noreply@certgate.com')
        @smtp_use_tls = Setting.get_boolean('smtp_use_tls', true)
      end

      def update_email_smtp
        # Get parameters
        smtp_host = params[:smtp_host]
        smtp_port = params[:smtp_port].to_i
        smtp_username = params[:smtp_username]
        smtp_password = params[:smtp_password]
        smtp_from_email = params[:smtp_from_email]
        smtp_use_tls = params[:smtp_use_tls] == '1'
        
        # Validate
        if smtp_host.blank?
          redirect_to admin_settings_email_smtp_path, alert: "SMTP Host는 필수입니다."
          return
        end
        
        if smtp_port < 1 || smtp_port > 65535
          redirect_to admin_settings_email_smtp_path, alert: "SMTP Port는 1에서 65535 사이여야 합니다."
          return
        end
        
        if smtp_from_email.blank? || !smtp_from_email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
          redirect_to admin_settings_email_smtp_path, alert: "유효한 From Email Address를 입력하세요."
          return
        end
        
        # Save settings
        Setting.set_string('smtp_host', smtp_host)
        Setting.set('smtp_port', smtp_port)
        Setting.set_string('smtp_username', smtp_username)
        Setting.set_string('smtp_password', smtp_password) unless smtp_password.blank?
        Setting.set_string('smtp_from_email', smtp_from_email)
        Setting.set_boolean('smtp_use_tls', smtp_use_tls)
        
        # Log the change
        setting = Setting.find_by(key: 'smtp_host') || Setting.new(key: 'smtp_host')
        AuditLogger.log(
          current_user, 
          setting, 
          'update_email_smtp', 
          "SMTP 설정 변경: #{smtp_host}:#{smtp_port}",
          { smtp_host: smtp_host, smtp_port: smtp_port, smtp_from_email: smtp_from_email },
          request.remote_ip
        )
        
        redirect_to admin_settings_email_smtp_path, 
          notice: "SMTP 설정이 성공적으로 업데이트되었습니다."
      end

      def test_email
        test_email_address = params[:test_email_address]
        
        if test_email_address.blank? || !test_email_address.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
          redirect_to admin_settings_email_smtp_path, alert: "유효한 테스트 이메일 주소를 입력하세요."
          return
        end
        
        begin
          # Load SMTP settings from database
          smtp_settings = {
            address: Setting.get_string('smtp_host', 'smtp.gmail.com'),
            port: Setting.get('smtp_port', 587).to_i,
            user_name: Setting.get_string('smtp_username', ''),
            password: Setting.get_string('smtp_password', ''),
            authentication: :plain,
            enable_starttls_auto: Setting.get_boolean('smtp_use_tls', true),
            openssl_verify_mode: 'none'  # SSL 인증서 검증 우회 (개발/테스트용)
          }
          
          # Temporarily configure ActionMailer with these settings
          original_settings = ActionMailer::Base.smtp_settings.dup
          ActionMailer::Base.smtp_settings = smtp_settings
          
          # Send test email
          TestMailer.test_email(test_email_address).deliver_now
          
          # Restore original settings
          ActionMailer::Base.smtp_settings = original_settings
          
          # Log the test
          AuditLogger.log(
            current_user,
            Setting.find_by(key: 'smtp_host') || Setting.new(key: 'smtp_host'),
            'test_email',
            "테스트 이메일 전송: #{test_email_address}",
            { to: test_email_address, smtp_host: smtp_settings[:address], smtp_port: smtp_settings[:port] },
            request.remote_ip
          )
          
          redirect_to admin_settings_email_smtp_path, 
            notice: "✅ 테스트 이메일이 #{test_email_address}(으)로 전송되었습니다. 수신함을 확인하세요."
        rescue => e
          redirect_to admin_settings_email_smtp_path, 
            alert: "❌ 테스트 이메일 전송 실패: #{e.message}"
        end
      end
    end
  end
end
