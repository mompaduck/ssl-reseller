class AddFailureReasonToCertificates < ActiveRecord::Migration[8.1]
  def change
    add_column :certificates, :failure_reason, :text
  end
end
