# frozen_string_literal: true

class AddRoleToBrawoCmsAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :brawo_cms_accounts, :role, :integer, null: false, default: 2
  end
end
