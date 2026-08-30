class CreateBrawoCmsAccounts < ActiveRecord::Migration[7.1]
  def change
    enable_extension "citext"

    create_table :brawo_cms_accounts do |t|
      t.integer :status, null: false, default: 2
      t.citext :email, null: false
      t.check_constraint "email ~ '^[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+$'", name: "valid_email"
      t.index :email, unique: true, where: "status IN (1, 2)"
      t.string :password_hash
    end

    create_table :brawo_cms_account_otp_keys, id: false do |t|
      t.bigint :id, primary_key: true
      t.foreign_key :brawo_cms_accounts, column: :id
      t.string :key, null: false
      t.integer :num_failures, null: false, default: 0
      t.datetime :last_use, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :brawo_cms_account_recovery_codes, primary_key: [:id, :code] do |t|
      t.bigint :id
      t.foreign_key :brawo_cms_accounts, column: :id
      t.string :code
    end

    create_table :brawo_cms_account_login_failures, id: false do |t|
      t.bigint :id, primary_key: true
      t.foreign_key :brawo_cms_accounts, column: :id
      t.integer :number, null: false, default: 1
    end

    create_table :brawo_cms_account_lockouts, id: false do |t|
      t.bigint :id, primary_key: true
      t.foreign_key :brawo_cms_accounts, column: :id
      t.string :key, null: false
      t.datetime :deadline, null: false
      t.datetime :email_last_sent
    end

    create_table :brawo_cms_account_active_session_keys, primary_key: [:brawo_cms_account_id, :session_id] do |t|
      t.references :brawo_cms_account, foreign_key: true
      t.string :session_id
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :last_use, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :brawo_cms_account_identities do |t|
      t.references :brawo_cms_account, null: false, foreign_key: { on_delete: :cascade }
      t.string :provider, null: false
      t.string :uid, null: false
      t.index [:provider, :uid], unique: true
    end
  end
end
