module Admin
  module Settings
    class LoggingRetentionController < Admin::BaseController
      def logging_retention
        # Load current settings from database or config
        # For now, we'll use placeholder values
        @audit_log_retention = Setting.get('audit_log_retention_days', 90)
        @issue_log_retention = Setting.get('issue_log_retention_days', 30)
      end

      def update_logging_retention
        audit_days = params[:audit_log_retention_days].to_i
        issue_days = params[:issue_log_retention_days].to_i
        
        # Validate
        if audit_days < 1 || audit_days > 3650
          redirect_to admin_settings_logging_retention_path, 
            alert: "Audit Log 보관 기간은 1일에서 3650일 사이여야 합니다."
          return
        end
        
        if issue_days < 1 || issue_days > 3650
          redirect_to admin_settings_logging_retention_path, 
            alert: "Issue Log 보관 기간은 1일에서 3650일 사이여야 합니다."
          return
        end
        
        # Save settings
        Setting.set('audit_log_retention_days', audit_days)
        Setting.set('issue_log_retention_days', issue_days)
        
        # Log the change (use a Setting record as auditable)
        setting = Setting.find_by(key: 'audit_log_retention_days') || Setting.new(key: 'audit_log_retention_days')
        AuditLogger.log(
          current_user, 
          setting, 
          'update_logging_retention', 
          "로그 보관 기간 변경: Audit(#{audit_days}일), Issue(#{issue_days}일)",
          { audit_days: audit_days, issue_days: issue_days },
          request.remote_ip
        )
        
        redirect_to admin_settings_logging_retention_path, 
          notice: "로그 보관 기간이 성공적으로 업데이트되었습니다."
      end
    end
  end
end
