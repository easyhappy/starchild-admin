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

ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "role", default: "viewer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ai_chat_keys", id: :serial, force: :cascade do |t|
    t.text "account"
    t.text "ai_api_key"
  end

  create_table "chat_recommendation_templates", id: :serial, force: :cascade do |t|
    t.string "display_text_en", limit: 64
    t.string "display_text_zh", limit: 64
    t.text "full_text_en"
    t.text "full_text_zh"
    t.text "category"
    t.integer "weight", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["display_text_en"], name: "idx_chat_rec_tpl_unique_en", unique: true, where: "(display_text_en IS NOT NULL)"
    t.index ["display_text_zh"], name: "idx_chat_rec_tpl_unique_zh", unique: true, where: "(display_text_zh IS NOT NULL)"
  end

  create_table "default_task_follow", id: :serial, force: :cascade do |t|
    t.text "user_id", null: false
    t.text "task_id", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["user_id", "task_id"], name: "default_task_follow_user_id_task_id_key", unique: true
  end

  create_table "holomind_context", primary_key: ["user_id", "thread_id", "msg_id"], force: :cascade do |t|
    t.text "user_id", null: false
    t.text "thread_id", null: false
    t.text "msg_id", null: false
    t.text "user_name"
    t.text "tg_id"
    t.jsonb "content", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
  end

  create_table "holomind_threads", primary_key: ["userid", "thread_id"], force: :cascade do |t|
    t.text "userid", null: false
    t.text "thread_id", null: false
    t.text "title"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["created_at"], name: "holomind_threads_created_at_idx"
    t.index ["userid"], name: "holomind_threads_userid_idx"
  end

# Could not dump table "humanized_recommendations" because of following StandardError
#   Unknown type 'vector(1536)' for column 'embedding'

  create_table "kols", id: :serial, force: :cascade do |t|
    t.text "kol_id"
    t.text "kol_name", null: false
    t.text "kol_avatar", default: ""
    t.text "description", default: ""
    t.text "cn_description", default: ""
    t.integer "weight", default: 0
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["kol_id"], name: "kols_kol_id_key", unique: true
    t.index ["kol_name"], name: "idx_kols_name", unique: true
  end

  create_table "recommendation_actions", id: :serial, force: :cascade do |t|
    t.integer "recommendation_id", null: false
    t.text "action_type", null: false
    t.datetime "action_timestamp", precision: nil, default: -> { "now()" }
    t.jsonb "additional_data", default: {}
    t.text "user_agent", default: ""
    t.text "ip_address", default: ""
    t.index ["action_type"], name: "idx_recommendation_actions_type"
    t.index ["recommendation_id"], name: "idx_recommendation_actions_rec_id"
    t.check_constraint "action_type = ANY (ARRAY['viewed'::text, 'clicked'::text, 'adopted'::text, 'ignored'::text, 'dismissed'::text, 'subscribed'::text, 'get_more_recommendations_clicked'::text, 'chart_button_clicked'::text])", name: "recommendation_actions_action_type_check"
  end

  create_table "recommendation_effectiveness", id: :serial, force: :cascade do |t|
    t.integer "recommendation_id", null: false
    t.text "effectiveness_metric", null: false
    t.float "metric_value", null: false
    t.datetime "measured_at", precision: nil, default: -> { "now()" }
    t.jsonb "additional_context", default: {}
    t.text "notes", default: ""
    t.index ["recommendation_id"], name: "idx_recommendation_effectiveness_rec_id"
    t.check_constraint "effectiveness_metric = ANY (ARRAY['task_completion'::text, 'user_engagement'::text, 'satisfaction'::text, 'conversion_rate'::text])", name: "recommendation_effectiveness_effectiveness_metric_check"
  end

  create_table "short_cuts", id: :serial, force: :cascade do |t|
    t.text "userid"
    t.text "content"
    t.index ["userid"], name: "idx_short_cuts_by_userid"
  end

  create_table "subscription_task", id: :serial, force: :cascade do |t|
    t.text "task_id", null: false
    t.text "user_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["user_id", "task_id"], name: "subscription_task_user_id_task_id_idx", unique: true
    t.index ["user_id", "updated_at"], name: "idx_subscription_task_user_updated", order: { updated_at: :desc }
  end

# Could not dump table "task" because of following StandardError
#   Unknown type 'vector(1536)' for column 'embedding'

  create_table "task_tokens", primary_key: "token_name", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "token_id", limit: 255
    t.integer "subscription_user_count", default: 0, null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.text "description", default: ""
    t.text "cn_description", default: ""
    t.index ["token_id"], name: "idx_task_tokens_token_id"
  end

  create_table "user_context", id: false, force: :cascade do |t|
    t.text "userid"
    t.text "thread_id"
    t.text "context"
    t.text "user_name"
    t.text "title"
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.index ["userid", "thread_id"], name: "user_context_userid_thread_id_idx", unique: true
  end

  create_table "user_feedback", primary_key: "feedback_id", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "user_id", null: false
    t.text "chat_id", null: false
    t.text "message_id", null: false
    t.text "feedback_type", null: false
    t.timestamptz "created_at", default: -> { "now()" }
    t.jsonb "extra_data", default: {}
    t.index ["created_at"], name: "idx_user_feedback_created_at"
    t.index ["feedback_type"], name: "idx_user_feedback_type"
    t.index ["message_id"], name: "idx_user_feedback_message_id"
    t.index ["user_id", "chat_id", "message_id"], name: "user_feedback_user_id_chat_id_message_id_key", unique: true
    t.index ["user_id", "created_at"], name: "idx_user_feedback_user_id_created_at"
    t.check_constraint "feedback_type = ANY (ARRAY['like'::text, 'dislike'::text])", name: "user_feedback_feedback_type_check"
  end

  create_table "user_info", primary_key: "userid", id: :text, force: :cascade do |t|
    t.jsonb "settings"
    t.text "user_name"
    t.text "avatar_url"
  end

  create_table "whitelist_accounts", force: :cascade do |t|
    t.binary "account"
    t.text "nft_id"
    t.text "burn_at"
    t.text "created_at", null: false
    t.text "updated_at", null: false
    t.text "mint_tx_status"
    t.text "mint_tx_hash"
    t.text "telegram_user_id"
    t.datetime "valid_at", precision: nil
    t.boolean "is_vip"
    t.index ["account"], name: "idx_whitelist_accounts_account", unique: true
    t.index ["account"], name: "idx_whitelist_accounts_by_address", unique: true
  end

  add_foreign_key "recommendation_actions", "humanized_recommendations", column: "recommendation_id", name: "recommendation_actions_recommendation_id_fkey", on_delete: :cascade
  add_foreign_key "recommendation_effectiveness", "humanized_recommendations", column: "recommendation_id", name: "recommendation_effectiveness_recommendation_id_fkey", on_delete: :cascade
end
