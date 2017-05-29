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

ActiveRecord::Schema.define(version: 20170529051952) do

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

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "ingredients", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "alias"
    t.string   "image"
    t.integer  "price"
    t.integer  "weight"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "discount"
    t.string   "texture"
    t.integer  "category_id"
    t.integer  "order_limit"
    t.string   "sale_mode"
    t.integer  "limit_count"
    t.index ["alias"], name: "index_ingredients_on_alias", using: :btree
    t.index ["category_id"], name: "index_ingredients_on_category_id", using: :btree
    t.index ["discount"], name: "index_ingredients_on_discount", using: :btree
    t.index ["name"], name: "index_ingredients_on_name", using: :btree
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
    t.string   "receiver_address"
    t.string   "receiver_phone"
    t.text     "remark",                   limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "pay_status"
    t.index ["distribute_at"], name: "index_orders_on_distribute_at", using: :btree
    t.index ["distributer_id"], name: "index_orders_on_distributer_id", using: :btree
    t.index ["order_no"], name: "index_orders_on_order_no", unique: true, using: :btree
    t.index ["pay_mode"], name: "index_orders_on_pay_mode", using: :btree
    t.index ["pay_status"], name: "index_orders_on_pay_status", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "nickname",               default: ""
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
    t.index ["nickname"], name: "index_users_on_nickname", using: :btree
    t.index ["open_id"], name: "index_users_on_open_id", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
  end

end
