class ChangeProviderToStringInProducts < ActiveRecord::Migration[8.1]
  def up
    # 1) 새 컬럼 추가
    add_column :products, :provider_new, :string

    # 2) 기존 정수 enum → 문자열 변환
    provider_map = {
      0 => "Sectigo",
      1 => "DigiCert",
      2 => "RapidSSL",
      3 => "Certum",
      4 => "Thawte",
      5 => "GeoTrust"
    }

    Product.reset_column_information
    Product.find_each do |p|
      p.update_column(:provider_new, provider_map[p.provider])
    end

    # 3) 기존 컬럼 제거 후 이름 변경
    remove_column :products, :provider
    rename_column :products, :provider_new, :provider
  end

  def down
    # 롤백 (optional)
    add_column :products, :provider_int, :integer

    provider_reverse = {
      "Sectigo"  => 0,
      "DigiCert" => 1,
      "RapidSSL" => 2,
      "Certum"   => 3,
      "Thawte"   => 4,
      "GeoTrust" => 5
    }

    Product.reset_column_information
    Product.find_each do |p|
      p.update_column(:provider_int, provider_reverse[p.provider])
    end

    remove_column :products, :provider
    rename_column :products, :provider_int, :provider
  end
end