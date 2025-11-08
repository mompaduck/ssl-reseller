class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum :certificate_type, { dv: 'dv', ov: 'ov', ev: 'ev' }
end