# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171113142243) do

  create_table "active_admin_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "namespace"
    t.text     "body",          limit: 65535
    t.string   "resource_type"
    t.integer  "resource_id"
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "gender"
    t.string   "phone"
    t.string   "garden"
    t.string   "house_number"
    t.boolean  "is_default"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_addresses_on_user_id", using: :btree
  end

  create_table "articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["user_id"], name: "index_articles_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "article_id"
    t.string   "content"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_comments_on_article_id", using: :btree
  end

  create_table "coupons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "desc"
    t.integer  "amount"
    t.integer  "price_limit"
    t.string   "coupon_type"
    t.datetime "used_at"
    t.datetime "valid_begin_at"
    t.datetime "valid_end_at"
    t.text     "extra_info",     limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["used_at"], name: "index_coupons_on_used_at", using: :btree
    t.index ["user_id"], name: "index_coupons_on_user_id", using: :btree
    t.index ["valid_begin_at"], name: "index_coupons_on_valid_begin_at", using: :btree
    t.index ["valid_end_at"], name: "index_coupons_on_valid_end_at", using: :btree
  end

  create_table "dishes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "image"
    t.text     "description",    limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "cooking_method", limit: 65535
    t.index ["name"], name: "index_dishes_on_name", using: :btree
  end

  create_table "dishes_ingredients", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "dish_id"
    t.integer  "ingredient_id"
    t.integer  "weight"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["dish_id"], name: "index_dish_ingredients_on_dish_id", using: :btree
    t.index ["ingredient_id"], name: "index_dish_ingredients_on_ingredient_id", using: :btree
  end

  create_table "gardens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "distribution_price"
    t.integer  "free_price"
    t.boolean  "visible",            default: true
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["visible"], name: "index_gardens_on_visible", using: :btree
  end

  create_table "history_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "action"
    t.integer  "user_id"
    t.integer  "order_id"
    t.text     "details",            limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "wholesale_order_id"
    t.index ["action"], name: "index_history_logs_on_action", using: :btree
    t.index ["order_id"], name: "index_history_logs_on_order_id", using: :btree
    t.index ["user_id"], name: "index_history_logs_on_user_id", using: :btree
    t.index ["wholesale_order_id"], name: "index_history_logs_on_wholesale_order_id", using: :btree
  end

  create_table "ingredients", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "alias"
    t.string   "image"
    t.integer  "price"
    t.integer  "original_price"
    t.text     "description",    limit: 65535
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "tags"
    t.string   "texture"
    t.integer  "category_id"
    t.integer  "order_limit"
    t.string   "unit_text"
    t.integer  "limit_count"
    t.integer  "sales_volume",                 default: 0
    t.integer  "priority",                     default: 0
    t.string   "secondary_tag"
    t.boolean  "is_hot",                       default: false
    t.integer  "stock_count"
    t.index ["alias"], name: "index_ingredients_on_alias", using: :btree
    t.index ["category_id"], name: "index_ingredients_on_category_id", using: :btree
    t.index ["name"], name: "index_ingredients_on_name", using: :btree
    t.index ["priority"], name: "index_ingredients_on_priority", using: :btree
    t.index ["tags"], name: "index_ingredients_on_tags", using: :btree
  end

  create_table "order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.string   "name"
    t.string   "img"
    t.integer  "count"
    t.integer  "price"
    t.string   "type"
    t.integer  "relation_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["order_id"], name: "index_order_items_on_order_id", using: :btree
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "order_no"
    t.integer  "user_id"
    t.string   "status"
    t.text     "item_details",             limit: 65535
    t.integer  "item_price"
    t.integer  "distribution_price"
    t.string   "free_distribution_reason"
    t.integer  "preferential_price"
    t.string   "preferential_reason"
    t.integer  "total_price"
    t.string   "pay_mode"
    t.datetime "distribute_at"
    t.integer  "distributer_id"
    t.string   "receiver_name"
    t.string   "receiver_garden"
    t.string   "receiver_address"
    t.string   "receiver_phone"
    t.text     "remark",                   limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "pay_status"
    t.text     "gifts",                    limit: 65535
    t.text     "item_list",                limit: 65535
    t.text     "admin_remark",             limit: 65535
    t.integer  "coupon_id"
    t.string   "campaign_code"
    t.integer  "referee_id"
    t.index ["distribute_at"], name: "index_orders_on_distribute_at", using: :btree
    t.index ["distributer_id"], name: "index_orders_on_distributer_id", using: :btree
    t.index ["order_no"], name: "index_orders_on_order_no", unique: true, using: :btree
    t.index ["pay_mode"], name: "index_orders_on_pay_mode", using: :btree
    t.index ["pay_status"], name: "index_orders_on_pay_status", using: :btree
    t.index ["receiver_garden"], name: "index_orders_on_receiver_garden", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "nickname",               default: "",              collation: "utf8mb4_general_ci"
    t.string   "encrypted_password",     default: ""
    t.string   "open_id"
    t.string   "phone"
    t.string   "user_name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "role"
    t.string   "email",                  default: "", null: false, collation: "utf8mb4_general_ci"
    t.string   "referral_code"
    t.integer  "referee_id"
    t.index ["nickname"], name: "index_users_on_nickname", length: { nickname: 191 }, using: :btree
    t.index ["open_id"], name: "index_users_on_open_id", unique: true, using: :btree
    t.index ["referee_id"], name: "index_users_on_referee_id", using: :btree
    t.index ["referral_code"], name: "index_users_on_referral_code", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
  end

  create_table "wholesale_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "alias"
    t.string   "mode"
    t.string   "cover_image"
    t.text     "detail_images", limit: 65535
    t.text     "summary",       limit: 65535
    t.text     "detail",        limit: 65535
    t.text     "tips",          limit: 65535
    t.integer  "min_count"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "visible",                     default: true
    t.index ["name"], name: "index_wholesale_entries_on_name", using: :btree
  end

  create_table "wholesale_instances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "wholesale_entry_id"
    t.string   "status"
    t.string   "mode"
    t.integer  "user_id"
    t.string   "name"
    t.integer  "min_count"
    t.integer  "max_count"
    t.integer  "current_count"
    t.datetime "close_at"
    t.date     "distribute_date_from"
    t.date     "distribute_date_to"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "distribute_scope"
    t.boolean  "visible",              default: true
    t.index ["close_at"], name: "index_wholesale_instances_on_close_at", using: :btree
    t.index ["user_id"], name: "index_wholesale_instances_on_user_id", using: :btree
    t.index ["wholesale_entry_id"], name: "index_wholesale_instances_on_wholesale_entry_id", using: :btree
  end

  create_table "wholesale_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "wholesale_entry_id"
    t.string   "name"
    t.string   "alias"
    t.string   "image"
    t.integer  "price"
    t.integer  "original_price"
    t.string   "unit_text"
    t.text     "description",        limit: 65535
    t.integer  "sales_volume",                     default: 0
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "limit_count"
    t.index ["wholesale_entry_id"], name: "index_wholesale_items_on_wholesale_entry_id", using: :btree
  end

  create_table "wholesale_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "order_no"
    t.string   "pay_status"
    t.string   "status"
    t.integer  "wholesale_instance_id"
    t.integer  "wholesale_item_id"
    t.integer  "item_count"
    t.text     "item_details",          limit: 65535
    t.integer  "item_price"
    t.integer  "preferential_price"
    t.integer  "total_price"
    t.datetime "distribute_at"
    t.string   "receiver_name"
    t.string   "receiver_garden"
    t.string   "receiver_address"
    t.string   "receiver_phone"
    t.string   "remark"
    t.string   "admin_remark"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["distribute_at"], name: "index_wholesale_orders_on_distribute_at", using: :btree
    t.index ["order_no"], name: "index_wholesale_orders_on_order_no", using: :btree
    t.index ["pay_status"], name: "index_wholesale_orders_on_pay_status", using: :btree
    t.index ["receiver_garden"], name: "index_wholesale_orders_on_receiver_garden", using: :btree
    t.index ["status"], name: "index_wholesale_orders_on_status", using: :btree
    t.index ["user_id"], name: "index_wholesale_orders_on_user_id", using: :btree
    t.index ["wholesale_instance_id"], name: "index_wholesale_orders_on_wholesale_instance_id", using: :btree
    t.index ["wholesale_item_id"], name: "index_wholesale_orders_on_wholesale_item_id", using: :btree
  end

end
