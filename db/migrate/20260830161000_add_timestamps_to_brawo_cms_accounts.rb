# frozen_string_literal: true

class AddTimestampsToBrawoCmsAccounts < ActiveRecord::Migration[7.1]
  def change
    change_table :brawo_cms_accounts, bulk: true do |t|
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    change_column_default :brawo_cms_accounts, :created_at, from: -> { "CURRENT_TIMESTAMP" }, to: nil
    change_column_default :brawo_cms_accounts, :updated_at, from: -> { "CURRENT_TIMESTAMP" }, to: nil
  end
end
