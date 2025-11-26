class AddPricingColumnsToProducts < ActiveRecord::Migration[8.1]
  def change
    # 기존 price를 selling_price로 이름 변경
    rename_column :products, :price, :selling_price
    
    # 새로운 가격 관리 컬럼 추가
    add_column :products, :cost_price, :integer, null: false, default: 0, comment: "Sectigo 원가"
    add_column :products, :margin_percentage, :decimal, precision: 5, scale: 2, comment: "마진율 (%)"
    add_column :products, :promo_code, :string, comment: "프로모션 코드"
    add_column :products, :promo_valid_until, :datetime, comment: "프로모션 종료일"
    add_column :products, :is_on_promotion, :boolean, default: false, comment: "프로모션 활성화 여부"
    
    # 인덱스 추가
    add_index :products, :cost_price
    add_index :products, :promo_code
    add_index :products, :is_on_promotion
  end
end
