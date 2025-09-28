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

ActiveRecord::Schema[7.0].define(version: 2025_09_28_151327) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "vector"

  create_table "accounts", comment: "User account information with EVM and Solana addresses", force: :cascade do |t|
    t.binary "evm_address"
    t.text "solana_address"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["evm_address"], name: "idx_accounts_by_address"
    t.index ["solana_address"], name: "idx_accounts_by_solana_address"
  end

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

  create_table "agent_code_change_logs", id: :uuid, default: -> { "uuid_generate_v4()" }, comment: "记录代码的所有变更和执行日志", force: :cascade do |t|
    t.uuid "code_id", null: false
    t.string "log_type", limit: 50, null: false, comment: "日志类型：execution(执行), edit(编辑), creation(创建), status_change(状态变更)"
    t.boolean "execution_success", comment: "执行是否成功"
    t.text "execution_output", comment: "执行输出"
    t.text "execution_error", comment: "执行错误信息"
    t.integer "execution_duration_ms", comment: "执行耗时(毫秒)"
    t.text "previous_code"
    t.text "new_code"
    t.text "edit_message"
    t.string "previous_status", limit: 20
    t.string "new_status", limit: 20
    t.string "user_id", limit: 255, null: false
    t.timestamptz "timestamp", default: -> { "CURRENT_TIMESTAMP" }
    t.jsonb "additional_data", comment: "额外的JSON数据"
    t.index ["code_id", "log_type", "timestamp"], name: "idx_change_logs_execution_recent", order: { timestamp: :desc }, where: "((log_type)::text = 'execution'::text)"
    t.index ["code_id", "timestamp"], name: "idx_change_logs_recent", order: { timestamp: :desc }
    t.index ["code_id"], name: "idx_change_logs_code_id"
    t.index ["execution_success"], name: "idx_change_logs_execution_success"
    t.index ["log_type"], name: "idx_change_logs_log_type"
    t.index ["timestamp"], name: "idx_change_logs_timestamp"
    t.index ["user_id"], name: "idx_change_logs_user_id"
    t.check_constraint "log_type::text = ANY (ARRAY['execution'::character varying::text, 'edit'::character varying::text, 'creation'::character varying::text, 'status_change'::character varying::text])", name: "agent_code_change_logs_log_type_check"
  end

  create_table "agent_codes", id: :uuid, default: -> { "uuid_generate_v4()" }, comment: "存储用户代码的主表", force: :cascade do |t|
    t.string "user_id", limit: 255, null: false, comment: "用户ID，用于关联用户"
    t.string "user_name", limit: 255, comment: "用户名称，可选字段"
    t.text "code", null: false, comment: "代码内容"
    t.text "message", comment: "用户对代码的描述"
    t.string "status", limit: 20, default: "active", comment: "代码状态：active(活跃) 或 inactive(非活跃)"
    t.integer "execution_count", default: 0, comment: "代码执行次数"
    t.timestamptz "last_execution", comment: "最后执行时间"
    t.boolean "last_execution_success", comment: "最后一次执行是否成功"
    t.timestamptz "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "last_edited"
    t.string "code_type", limit: 50, default: "oneshot", comment: "代码类型：oneshot(一次性), monitoring(监控), service(服务)"
    t.string "process_id", limit: 255, comment: "进程ID，用于跟踪运行中的代码进程"
    t.index ["code_type"], name: "idx_agent_codes_code_type"
    t.index ["created_at"], name: "idx_agent_codes_created_at"
    t.index ["last_execution"], name: "idx_agent_codes_last_execution"
    t.index ["process_id"], name: "idx_agent_codes_process_id"
    t.index ["status"], name: "idx_agent_codes_status"
    t.index ["user_id", "code_type"], name: "idx_agent_codes_user_type"
    t.index ["user_id", "status"], name: "idx_agent_codes_user_status"
    t.index ["user_id"], name: "idx_agent_codes_user_id"
    t.check_constraint "code_type::text = ANY (ARRAY['oneshot'::character varying::text, 'monitoring'::character varying::text, 'service'::character varying::text])", name: "agent_codes_code_type_check"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text])", name: "agent_codes_status_check"
  end

  create_table "ai_chat_keys", comment: "AI API keys for chat functionality", force: :cascade do |t|
    t.text "account"
    t.text "ai_api_key"
    t.index ["account"], name: "idx_ai_chat_keys_account"
    t.index ["account"], name: "idx_ai_chat_keys_by_account", unique: true
  end

  create_table "alert_notifications", force: :cascade do |t|
    t.text "market_id"
    t.text "coingecko_symbol"
    t.text "alert_type"
    t.text "alert_query"
    t.text "ai_content"
    t.text "alert_options"
    t.timestamptz "created_at", null: false
    t.index ["market_id"], name: "idx_alert_notifications_by_market_id"
  end

  create_table "async_job_schedulers", id: :serial, force: :cascade do |t|
    t.string "source_id", limit: 255, null: false
    t.string "source_type", limit: 100, null: false
    t.string "job_type", limit: 100, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["job_type"], name: "idx_async_job_schedulers_job_type"
    t.index ["source_id"], name: "idx_async_job_schedulers_source_id"
    t.index ["source_type"], name: "idx_async_job_schedulers_source_type"
  end

  create_table "broker_accounts", id: false, force: :cascade do |t|
    t.text "account", null: false
    t.text "telegram_user_id", null: false
    t.text "broker", null: false
    t.index ["account"], name: "broker_accounts_account_idx"
    t.index ["telegram_user_id"], name: "broker_accounts_telegram_user_id_idx"
  end

  create_table "candidates", force: :cascade do |t|
    t.text "account"
    t.text "user_agent"
    t.text "ip"
    t.text "created_at", null: false
    t.text "updated_at", null: false
    t.text "telegram_user_name"
    t.text "telegram_id"
  end

  create_table "chart_img_tokens", id: :serial, comment: "Chart image token mappings", force: :cascade do |t|
    t.text "symbol", null: false
    t.text "network"
    t.text "description"
    t.index ["network"], name: "idx_chart_img_tokens_network"
    t.index ["symbol", "network"], name: "chart_img_tokens_symbol_network_key", unique: true
    t.index ["symbol"], name: "idx_chart_img_tokens_symbol"
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

  create_table "chat_records", primary_key: "record_id", comment: "Store all Telegram chat messages including private and group chats", force: :cascade do |t|
    t.text "chat_id", null: false, comment: "Chat identifier: user_id for private chat, group_id for group chat"
    t.text "chat_type", null: false, comment: "Chat type: private or group"
    t.text "user_id", null: false, comment: "Telegram user ID who sent the message"
    t.text "user_name"
    t.text "user_username"
    t.text "message_id", null: false, comment: "Telegram message ID"
    t.text "message_text"
    t.text "message_type", default: "text"
    t.text "reply_to_message_id"
    t.text "forward_from_chat_id"
    t.boolean "is_bot_mentioned", default: false, comment: "Whether bot was mentioned in the message"
    t.boolean "has_keyword_trigger", default: false, comment: "Whether message contains trigger keywords"
    t.jsonb "extra_data", default: {}, comment: "Additional message metadata in JSON format"
    t.timestamptz "created_at", default: -> { "now()" }
    t.index ["chat_id", "created_at"], name: "idx_chat_records_chat_id_created_at", order: { created_at: :desc }
    t.index ["chat_id", "message_id"], name: "idx_chat_records_unique_message", unique: true
    t.index ["chat_type"], name: "idx_chat_records_chat_type"
    t.index ["is_bot_mentioned", "has_keyword_trigger"], name: "idx_chat_records_bot_triggers"
    t.index ["user_id", "created_at"], name: "idx_chat_records_user_id_created_at", order: { created_at: :desc }
    t.check_constraint "chat_type = ANY (ARRAY['private'::text, 'group'::text])", name: "chat_records_chat_type_check"
  end

  create_table "coin_markets", id: :text, comment: "Cryptocurrency market data", force: :cascade do |t|
    t.text "symbol"
    t.text "name"
    t.text "image"
    t.text "market_cap"
    t.integer "market_cap_rank"
    t.text "last_updated"
  end

  create_table "coingecko_token_mappings", primary_key: "token", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.text "token_alias"
  end

  create_table "default_task_follow", id: :serial, force: :cascade do |t|
    t.text "user_id", null: false
    t.text "task_id", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["user_id", "task_id"], name: "default_task_follow_user_id_task_id_key", unique: true
  end

  create_table "default_websearch_words", id: :serial, force: :cascade do |t|
    t.text "word", null: false
    t.index ["word"], name: "default_websearch_words_word_key", unique: true
  end

  create_table "favorite_tokens", force: :cascade do |t|
    t.text "token_id"
    t.text "account"
    t.timestamptz "created_at", null: false
    t.index ["account"], name: "idx_favorite_tokens_by_account"
  end

  create_table "holomind_context", primary_key: ["user_id", "thread_id", "msg_id"], comment: "Holomind AI context storage", force: :cascade do |t|
    t.text "user_id", null: false
    t.text "thread_id", null: false
    t.text "msg_id", null: false
    t.text "user_name"
    t.text "tg_id"
    t.jsonb "content", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.index ["user_id"], name: "idx_holomind_context_user_id"
  end

  create_table "holomind_source", primary_key: ["user_id", "thread_id", "msg_id", "source"], comment: "Holomind source information", force: :cascade do |t|
    t.text "user_id", null: false
    t.text "thread_id", null: false
    t.text "msg_id", null: false
    t.text "source", null: false
    t.text "source_info"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
  end

  create_table "holomind_threads", primary_key: ["userid", "thread_id"], comment: "Holomind conversation threads", force: :cascade do |t|
    t.text "userid", null: false
    t.text "thread_id", null: false
    t.text "title"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.index ["created_at"], name: "holomind_threads_created_at_idx"
    t.index ["created_at"], name: "idx_holomind_threads_created_at"
    t.index ["userid"], name: "holomind_threads_userid_idx"
    t.index ["userid"], name: "idx_holomind_threads_userid"
  end

# Could not dump table "humanized_recommendations" because of following StandardError
#   Unknown type 'vector(1536)' for column 'embedding'

  create_table "kols", id: :serial, force: :cascade do |t|
    t.text "kol_name", null: false
    t.text "kol_avatar", default: ""
    t.integer "weight", default: 0
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.text "kol_id"
    t.text "description"
    t.text "cn_description", default: ""
    t.index ["kol_name"], name: "idx_kols_name", unique: true
  end

  create_table "memory_init_status", id: :integer, default: 1, force: :cascade do |t|
    t.string "status", limit: 20, default: "PENDING", null: false
    t.timestamptz "started_at"
    t.timestamptz "finished_at"
    t.integer "total_users_at_start", default: 0
    t.integer "total_contexts_at_start", default: 0
    t.integer "max_contexts_per_user_at_start", default: 0
    t.integer "processed_users", default: 0
    t.text "last_error"
    t.string "lock_host", limit: 255
    t.integer "version", default: 1
    t.timestamptz "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamptz "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["status"], name: "idx_memory_init_status_status"
    t.check_constraint "id = 1", name: "single_row_check"
    t.check_constraint "status::text = ANY (ARRAY['PENDING'::character varying::text, 'RUNNING'::character varying::text, 'DONE'::character varying::text, 'FAILED'::character varying::text])", name: "memory_init_status_status_check"
  end

  create_table "migrations", id: { type: :string, limit: 255 }, force: :cascade do |t|
  end

  create_table "nft_icons", force: :cascade do |t|
    t.text "nft_id", null: false
    t.text "icon_url", null: false
    t.text "created_at", null: false
    t.text "updated_at", null: false
    t.index ["nft_id"], name: "idx_nft_icons_nft_id", unique: true
  end

  create_table "old_user_recommended_tasks", comment: "Store recommended tasks for old users to re-engage them", force: :cascade do |t|
    t.bigint "response_id", null: false, comment: "Reference to the old_user_responses record"
    t.text "user_id", null: false, comment: "Telegram user ID"
    t.jsonb "recommended_task_ids", default: [], comment: "Array of existing task IDs that were recommended"
    t.text "task_generation_prompt", comment: "Prompt used to generate new tasks"
    t.jsonb "generated_tasks", default: [], comment: "Array of newly generated task objects"
    t.text "review_status", default: "pending", comment: "Manual review status by admin"
    t.text "reviewer_notes", comment: "Admin notes during review process"
    t.text "reviewer_id", comment: "ID of admin who reviewed the tasks"
    t.text "push_status", default: "not_sent", comment: "Status of notification push to user"
    t.timestamptz "push_time", comment: "When notification was sent to user"
    t.text "push_error", comment: "Error message if push failed"
    t.timestamptz "created_at", default: -> { "now()" }
    t.timestamptz "updated_at", default: -> { "now()" }
    t.index ["created_at"], name: "idx_old_user_recommended_tasks_created_at", order: :desc
    t.index ["push_status"], name: "idx_old_user_recommended_tasks_push_status"
    t.index ["response_id"], name: "idx_old_user_recommended_tasks_response_id"
    t.index ["review_status", "push_status", "created_at"], name: "idx_old_user_recommended_tasks_status_combo", order: { created_at: :desc }
    t.index ["review_status"], name: "idx_old_user_recommended_tasks_review_status"
    t.index ["updated_at"], name: "idx_old_user_recommended_tasks_updated_at", order: :desc
    t.index ["user_id"], name: "idx_old_user_recommended_tasks_user_id"
    t.check_constraint "push_status = ANY (ARRAY['not_sent'::text, 'sent'::text, 'failed'::text])", name: "old_user_recommended_tasks_push_status_check"
    t.check_constraint "review_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'sent'::text])", name: "old_user_recommended_tasks_review_status_check"
  end

# Could not dump table "old_user_responses" because of following StandardError
#   Unknown type 'vector(1536)' for column 'response_embedding'

  create_table "orderly_account_private_keys", force: :cascade do |t|
    t.binary "account", null: false
    t.text "orderly_key", null: false
    t.binary "private_key", null: false
    t.binary "nonce", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["account", "created_at"], name: "orderly_account_pk_created_at_key"
    t.index ["orderly_key"], name: "orderly_account_pk_unique_key", unique: true
  end

  create_table "qr_code_tokens", force: :cascade do |t|
    t.text "token"
    t.binary "evm_address"
    t.text "solana_address"
    t.text "status", null: false
    t.text "ip_address", null: false
    t.text "device", null: false
    t.text "location", null: false
    t.timestamptz "confirmed_at", null: false
    t.timestamptz "scanned_at", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["token"], name: "idx_qr_code_tokens_by_token", unique: true
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

  create_table "short_cuts", id: :serial, comment: "User-defined shortcuts", force: :cascade do |t|
    t.text "userid"
    t.text "content"
    t.index ["userid"], name: "idx_short_cuts_by_userid"
  end

  create_table "subscription_task", id: :serial, comment: "User task subscriptions", force: :cascade do |t|
    t.text "task_id", null: false
    t.text "user_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.index ["task_id"], name: "idx_subscription_task_task_id"
    t.index ["user_id", "task_id"], name: "subscription_task_user_id_task_id_idx", unique: true
    t.index ["user_id", "task_id"], name: "subscription_task_user_id_task_id_key", unique: true
    t.index ["user_id", "updated_at"], name: "idx_subscription_task_user_updated", order: { updated_at: :desc }
    t.index ["user_id"], name: "idx_subscription_task_user_id"
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

  create_table "task_trigger_history", id: :serial, force: :cascade do |t|
    t.text "task_id", null: false
    t.text "message", null: false
    t.boolean "is_error", default: false, null: false
    t.text "cn_message", null: false
    t.text "en_message", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
  end

  create_table "team_state", primary_key: "userid", id: { type: :string, limit: 255 }, comment: "Team collaboration state management", force: :cascade do |t|
    t.text "state"
  end

  create_table "token_mappings", force: :cascade do |t|
    t.text "coin_gecko_id"
    t.text "symbol"
  end

  create_table "tweets", force: :cascade do |t|
    t.text "tweet_id"
    t.text "tweet_text"
    t.text "type"
    t.json "full_content"
    t.text "author_name"
    t.bigint "retweet_count"
    t.bigint "reply_count"
    t.bigint "like_count"
    t.bigint "quote_count"
    t.bigint "view_count"
    t.text "data_source"
    t.timestamptz "tweet_created_at"
    t.timestamptz "created_at", null: false
    t.index ["author_name"], name: "idx_tweets_by_author_id"
    t.index ["tweet_created_at"], name: "idx_tweets_by_created_at"
    t.index ["tweet_id"], name: "idx_tweets_by_tweet_id"
  end

  create_table "user_active_codes", primary_key: ["user_id", "code_id"], comment: "存储用户当前活跃的代码列表，支持多个活跃代码", force: :cascade do |t|
    t.string "user_id", limit: 255, null: false
    t.uuid "code_id", null: false
    t.timestamptz "added_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["code_id"], name: "idx_user_active_codes_code_id"
    t.index ["user_id"], name: "idx_user_active_codes_user_id"
  end

  create_table "user_context", id: false, comment: "User chat history and context", force: :cascade do |t|
    t.string "userid", limit: 255, null: false
    t.text "context"
    t.text "user_name"
    t.datetime "updated_at", precision: nil
    t.text "thread_id", default: "-"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.text "inner_msg"
    t.text "msg_id"
    t.text "tg_msg_id"
    t.index ["thread_id"], name: "idx_user_context_thread_id"
    t.index ["userid", "thread_id"], name: "user_context_userid_thread_id_idx", unique: true
    t.index ["userid", "thread_id"], name: "user_context_userid_thread_id_key", unique: true
    t.index ["userid"], name: "idx_user_context_userid"
  end

  create_table "user_extended_settings", primary_key: "user_id", id: :text, force: :cascade do |t|
    t.jsonb "summary", default: {"tracked_tokens"=>[], "user_interests"=>[], "user_preferences"=>""}
    t.text "last_msg_id"
    t.datetime "last_created_at", precision: nil
    t.datetime "last_summary_time", precision: nil
    t.datetime "last_resummary_time", precision: nil
    t.integer "merge_count", default: 0
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.jsonb "facts", default: []
    t.text "facts_last_msg_id"
    t.datetime "facts_last_created_at", precision: nil
    t.datetime "facts_last_run_time", precision: nil
    t.integer "facts_merge_count", default: 0
  end

  create_table "user_extended_settings_runs", force: :cascade do |t|
    t.text "user_id", null: false
    t.text "run_type", null: false
    t.integer "messages_count"
    t.datetime "window_start", precision: nil
    t.datetime "window_end", precision: nil
    t.jsonb "old_summary"
    t.jsonb "new_delta"
    t.jsonb "merged_summary"
    t.text "status", default: "success", null: false
    t.text "error"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.index ["user_id", "created_at"], name: "idx_ues_runs_user_created_at", order: { created_at: :desc }
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

  create_table "user_info", primary_key: "userid", id: :text, comment: "User basic information and settings", force: :cascade do |t|
    t.jsonb "settings", default: {}
    t.text "user_name"
    t.text "avatar_url"
    t.string "user_source", limit: 255, default: "unknown"
    t.index ["userid"], name: "idx_user_info_userid"
  end

  create_table "user_read_notifications", force: :cascade do |t|
    t.bigint "notification_id"
    t.text "account"
    t.timestamptz "created_at", null: false
    t.index ["account"], name: "idx_user_read_notifications_by_account"
  end

  create_table "user_report", primary_key: "report_id", id: :uuid, default: nil, comment: "User reports and analytics", force: :cascade do |t|
    t.text "content", null: false
    t.text "user_id", null: false
    t.text "user_name"
    t.datetime "creat_at", precision: nil
    t.text "msg_id"
    t.jsonb "extra"
    t.index ["user_id"], name: "idx_user_report_user_id"
  end

  create_table "user_settings", primary_key: "userid", id: :text, comment: "User settings storage", force: :cascade do |t|
    t.jsonb "settings"
  end

  create_table "users", primary_key: ["userid", "chain"], comment: "User wallet information with composite primary key (userid, chain)", force: :cascade do |t|
    t.string "userid", limit: 255, null: false
    t.string "wallet_address", limit: 255
    t.text "private_key"
    t.text "chain", default: "SOLANA", null: false
    t.index ["userid"], name: "idx_users_userid"
  end

  create_table "whitelist_accounts", force: :cascade do |t|
    t.binary "account"
    t.text "nft_id"
    t.text "burn_at"
    t.text "created_at", null: false
    t.text "updated_at", null: false
    t.text "mint_tx_hash"
    t.text "mint_tx_status"
    t.text "telegram_user_id"
    t.text "burn_tx_hash"
    t.text "burn_status"
    t.datetime "valid_at", precision: nil
    t.boolean "is_vip"
    t.datetime "last_visit_at", precision: nil
    t.text "memo"
    t.index ["account"], name: "idx_whitelist_accounts_account", unique: true
    t.index ["account"], name: "idx_whitelist_accounts_by_address", unique: true
  end

  add_foreign_key "agent_code_change_logs", "agent_codes", column: "code_id", name: "agent_code_change_logs_code_id_fkey", on_delete: :cascade
  add_foreign_key "old_user_recommended_tasks", "old_user_responses", column: "response_id", name: "old_user_recommended_tasks_response_id_fkey", on_delete: :cascade
  add_foreign_key "recommendation_actions", "humanized_recommendations", column: "recommendation_id", name: "recommendation_actions_recommendation_id_fkey", on_delete: :cascade
  add_foreign_key "recommendation_effectiveness", "humanized_recommendations", column: "recommendation_id", name: "recommendation_effectiveness_recommendation_id_fkey", on_delete: :cascade
  add_foreign_key "user_active_codes", "agent_codes", column: "code_id", name: "user_active_codes_code_id_fkey", on_delete: :cascade
end
