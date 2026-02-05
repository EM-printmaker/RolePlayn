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

ActiveRecord::Schema[7.2].define(version: 2026_02_04_214055) do
  # These are extensions that must be enabled in order to support this database
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

  create_table "character_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "city_id", null: false
    t.bigint "character_id", null: false
    t.bigint "expression_id", null: false
    t.date "assigned_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_assignments_on_character_id"
    t.index ["city_id"], name: "index_character_assignments_on_city_id"
    t.index ["expression_id"], name: "index_character_assignments_on_expression_id"
    t.index ["user_id", "city_id", "assigned_date"], name: "unique_character_per_user_city_day", unique: true
    t.index ["user_id"], name: "index_character_assignments_on_user_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_characters_on_city_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "world_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target_scope_type", default: 0
    t.bigint "target_world_id"
    t.string "slug"
    t.index ["slug"], name: "index_cities_on_slug", unique: true
    t.index ["target_world_id"], name: "index_cities_on_target_world_id"
    t.index ["world_id"], name: "index_cities_on_world_id"
  end

  create_table "expressions", force: :cascade do |t|
    t.integer "emotion_type"
    t.integer "level"
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_expressions_on_character_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reply_subject"
    t.text "reply_body"
    t.datetime "reply_sent_at"
    t.integer "category"
    t.index ["reply_sent_at"], name: "index_inquiries_on_reply_sent_at"
  end

  create_table "posts", force: :cascade do |t|
    t.text "content"
    t.bigint "character_id", null: false
    t.bigint "expression_id", null: false
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sender_session_token"
    t.index ["character_id", "created_at"], name: "index_posts_on_character_id_and_created_at"
    t.index ["character_id"], name: "index_posts_on_character_id"
    t.index ["city_id", "created_at"], name: "index_posts_on_city_id_and_created_at"
    t.index ["city_id"], name: "index_posts_on_city_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["expression_id"], name: "index_posts_on_expression_id"
    t.index ["sender_session_token"], name: "index_posts_on_sender_session_token"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "login_id"
    t.integer "role", default: 0, null: false
    t.datetime "suspended_at"
    t.text "suspended_reason"
    t.integer "failed_attempts", default: 0, null: false
    t.integer "integer", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "datetime"
    t.string "unlock_token"
    t.string "string"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "worlds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_global", default: false, null: false
    t.string "slug"
    t.index ["slug"], name: "index_worlds_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "character_assignments", "characters"
  add_foreign_key "character_assignments", "cities"
  add_foreign_key "character_assignments", "expressions"
  add_foreign_key "character_assignments", "users"
  add_foreign_key "characters", "cities"
  add_foreign_key "cities", "worlds"
  add_foreign_key "expressions", "characters"
  add_foreign_key "posts", "characters"
  add_foreign_key "posts", "cities"
  add_foreign_key "posts", "expressions"
end
