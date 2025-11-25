class AddDcvFieldsToCertificates < ActiveRecord::Migration[8.1]
  def change
    add_column :certificates, :dcv_method, :string
    add_column :certificates, :dcv_email, :string
    add_column :certificates, :dcv_file_url, :string
    add_column :certificates, :dcv_file_content, :text
    add_column :certificates, :dcv_cname_host, :string
    add_column :certificates, :dcv_cname_value, :string
    add_column :certificates, :csr_parsed_data, :json
  end
end
