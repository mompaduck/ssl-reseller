class ChangeProductEnumsToInteger < ActiveRecord::Migration[8.0]
  def up
    # 1) 임시 컬럼 추가
    add_column :products, :domain_type_tmp, :integer
    add_column :products, :validation_type_tmp, :integer

    # 2) 문자열 → 정수 매핑 업데이트
    execute <<~SQL
      UPDATE products
      SET domain_type_tmp =
        CASE domain_type
          WHEN 'single' THEN 0
          WHEN 'multi' THEN 1
          WHEN 'wildcard' THEN 2
        END;
    SQL

    execute <<~SQL
      UPDATE products
      SET validation_type_tmp =
        CASE validation_type
          WHEN 'DV' THEN 0
          WHEN 'OV' THEN 1
          WHEN 'EV' THEN 2
        END;
    SQL

    # 3) 기존 컬럼 삭제
    remove_column :products, :domain_type
    remove_column :products, :validation_type

    # 4) 임시 컬럼을 기존 이름으로 변경
    rename_column :products, :domain_type_tmp, :domain_type
    rename_column :products, :validation_type_tmp, :validation_type
  end

  def down
    # 롤백 시 다시 문자열로 복원 (원하는 경우)
    add_column :products, :domain_type_str, :string
    add_column :products, :validation_type_str, :string

    execute <<~SQL
      UPDATE products
      SET domain_type_str =
        CASE domain_type
          WHEN 0 THEN 'single'
          WHEN 1 THEN 'wildcard'
          WHEN 2 THEN 'multi'
        END;
    SQL

    execute <<~SQL
      UPDATE products
      SET validation_type_str =
        CASE validation_type
          WHEN 0 THEN 'DV'
          WHEN 1 THEN 'OV'
          WHEN 2 THEN 'EV'
        END;
    SQL

    remove_column :products, :domain_type
    remove_column :products, :validation_type

    rename_column :products, :domain_type_str, :domain_type
    rename_column :products, :validation_type_str, :validation_type
  end
end