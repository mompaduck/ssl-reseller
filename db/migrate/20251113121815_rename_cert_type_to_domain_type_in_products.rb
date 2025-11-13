# frozen_string_literal: true

class RenameCertTypeToDomainTypeInProducts < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :cert_type, :domain_type
  end
end