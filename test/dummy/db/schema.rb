# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_08_30_161000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "brawo_cms_account_active_session_keys", primary_key: ["brawo_cms_account_id", "session_id"], force: :cascade do |t|
    t.bigint "brawo_cms_account_id", null: false
    t.string "session_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "last_use", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["brawo_cms_account_id"], name: "idx_on_brawo_cms_account_id_12a9f5b20a"
  end

  create_table "brawo_cms_account_identities", force: :cascade do |t|
    t.bigint "brawo_cms_account_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.index ["brawo_cms_account_id"], name: "index_brawo_cms_account_identities_on_brawo_cms_account_id"
    t.index ["provider", "uid"], name: "index_brawo_cms_account_identities_on_provider_and_uid", unique: true
  end

  create_table "brawo_cms_account_lockouts", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent"
  end

  create_table "brawo_cms_account_login_failures", force: :cascade do |t|
    t.integer "number", default: 1, null: false
  end

  create_table "brawo_cms_account_otp_keys", force: :cascade do |t|
    t.string "key", null: false
    t.integer "num_failures", default: 0, null: false
    t.datetime "last_use", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "brawo_cms_account_recovery_codes", primary_key: ["id", "code"], force: :cascade do |t|
    t.bigint "id", null: false
    t.string "code", null: false
  end

  create_table "brawo_cms_accounts", force: :cascade do |t|
    t.integer "status", default: 2, null: false
    t.citext "email", null: false
    t.string "password_hash"
    t.integer "role", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_brawo_cms_accounts_on_email", unique: true, where: "(status = ANY (ARRAY[1, 2]))"
    t.check_constraint "email ~ '^[^,;@ \r\n]+@[^,@; \r\n]+.[^,@; \r\n]+$'::citext", name: "valid_email"
  end

  create_table "brawo_cms_contents", force: :cascade do |t|
    t.string "type", null: false
    t.string "title"
    t.string "slug"
    t.text "description"
    t.jsonb "fields", default: {}, null: false
    t.string "status", default: "draft"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fields"], name: "index_brawo_cms_contents_on_fields", using: :gin
    t.index ["status"], name: "index_brawo_cms_contents_on_status"
    t.index ["type", "slug"], name: "index_brawo_cms_contents_on_type_and_slug", unique: true
    t.index ["type"], name: "index_brawo_cms_contents_on_type"
  end

  create_table "brawo_cms_media", force: :cascade do |t|
    t.string "title"
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brawo_cms_taxonomies", force: :cascade do |t|
    t.string "type", null: false
    t.string "name"
    t.string "slug"
    t.text "description"
    t.jsonb "fields", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fields"], name: "index_brawo_cms_taxonomies_on_fields", using: :gin
    t.index ["slug"], name: "index_brawo_cms_taxonomies_on_slug", unique: true
    t.index ["type"], name: "index_brawo_cms_taxonomies_on_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "brawo_cms_account_active_session_keys", "brawo_cms_accounts"
  add_foreign_key "brawo_cms_account_identities", "brawo_cms_accounts", on_delete: :cascade
  add_foreign_key "brawo_cms_account_lockouts", "brawo_cms_accounts", column: "id"
  add_foreign_key "brawo_cms_account_login_failures", "brawo_cms_accounts", column: "id"
  add_foreign_key "brawo_cms_account_otp_keys", "brawo_cms_accounts", column: "id"
  add_foreign_key "brawo_cms_account_recovery_codes", "brawo_cms_accounts", column: "id"
end
