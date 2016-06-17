# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160617054141) do

  create_table "addresses", force: :cascade do |t|
    t.string   "province",      limit: 255
    t.string   "city",          limit: 255
    t.string   "region",        limit: 255
    t.string   "detail",        limit: 255
    t.integer  "user_id",       limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "area",          limit: 255
    t.string   "receive_name",  limit: 255
    t.string   "receive_phone", limit: 255
    t.integer  "default",       limit: 4,   default: 0
    t.integer  "shop_type",     limit: 1
    t.string   "unique_id",     limit: 255
  end

  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "adverts", force: :cascade do |t|
    t.string   "ads_image",       limit: 255
    t.integer  "product_id",      limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "sub_category_id", limit: 4
    t.string   "unique_id",       limit: 255
  end

  add_index "adverts", ["product_id"], name: "index_adverts_on_product_id", using: :btree
  add_index "adverts", ["sub_category_id"], name: "index_adverts_on_sub_category_id", using: :btree

  create_table "cars", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "product_id",  limit: 4
    t.integer  "product_num", limit: 4
    t.integer  "user_id",     limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "unique_id",   limit: 255
  end

  add_index "cart_items", ["unique_id"], name: "index_cart_items_on_unique_id", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "sort",       limit: 4,   default: 1, null: false
    t.string   "desc",       limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "unique_id",  limit: 255
  end

  add_index "categories", ["sort"], name: "index_categories_on_sort", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliverymen", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "detail_categories", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "sort",            limit: 4,   default: 1, null: false
    t.integer  "category_id",     limit: 4
    t.integer  "sub_category_id", limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "desc",            limit: 255
    t.string   "unique_id",       limit: 255
  end

  add_index "detail_categories", ["category_id"], name: "index_detail_categories_on_category_id", using: :btree
  add_index "detail_categories", ["sort"], name: "index_detail_categories_on_sort", using: :btree
  add_index "detail_categories", ["sub_category_id"], name: "index_detail_categories_on_sub_category_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "product_id", limit: 4
    t.string   "unique_id",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "favorites", ["product_id"], name: "index_favorites_on_product_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "hot_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "desc",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "unique_id",  limit: 255
  end

  create_table "images", force: :cascade do |t|
    t.string   "image",       limit: 255
    t.string   "target_type", limit: 255
    t.integer  "target_id",   limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "members", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "role",                   limit: 4
    t.integer  "promoter_id",            limit: 4
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree
  add_index "members", ["promoter_id"], name: "index_members_on_promoter_id", using: :btree
  add_index "members", ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "messageable_id",   limit: 4
    t.string   "messageable_type", limit: 255
    t.string   "title",            limit: 255
    t.string   "info",             limit: 255
    t.integer  "is_new",           limit: 1,   default: 0, null: false
    t.integer  "status",           limit: 1,   default: 0, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "messages", ["messageable_id", "messageable_type"], name: "messageable_index", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "state",          limit: 4
    t.string   "order_no",       limit: 255
    t.string   "phone_num",      limit: 255
    t.string   "receive_name",   limit: 255
    t.string   "area",           limit: 255
    t.string   "detail",         limit: 255
    t.datetime "delivery_time"
    t.datetime "complete_time"
    t.integer  "address_id",     limit: 4
    t.integer  "user_id",        limit: 4
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "unique_id",      limit: 255
    t.decimal  "order_money",                precision: 12, scale: 2, default: 0.0
    t.string   "remarks",        limit: 255
    t.integer  "deliveryman_id", limit: 4
    t.integer  "car_id",         limit: 4
  end

  add_index "orders", ["address_id"], name: "index_orders_on_address_id", using: :btree
  add_index "orders", ["car_id"], name: "index_orders_on_car_id", using: :btree
  add_index "orders", ["deliveryman_id"], name: "index_orders_on_deliveryman_id", using: :btree
  add_index "orders", ["order_no"], name: "index_orders_on_order_no", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "orders_products", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "order_id",      limit: 4
    t.integer  "product_id",    limit: 4
    t.integer  "product_num",   limit: 4
    t.decimal  "product_price",           precision: 12, scale: 2, default: 0.0
    t.integer  "status",        limit: 1,                          default: 0,   null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "orders_products", ["order_id"], name: "index_orders_products_on_order_id", using: :btree
  add_index "orders_products", ["product_id"], name: "index_orders_products_on_product_id", using: :btree
  add_index "orders_products", ["user_id"], name: "index_orders_products_on_user_id", using: :btree

  create_table "product_admins", force: :cascade do |t|
    t.integer  "product_id",     limit: 4
    t.string   "product_name",   limit: 255
    t.integer  "product_num",    limit: 4
    t.string   "stock_business", limit: 255
    t.decimal  "stock_price",                precision: 12, scale: 2, default: 0.0
    t.datetime "stock_time"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
  end

  add_index "product_admins", ["product_id"], name: "index_product_admins_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "sort",               limit: 4,                            default: 1,   null: false
    t.integer  "state",              limit: 4
    t.string   "image",              limit: 255
    t.string   "unit_id",            limit: 255
    t.integer  "stock_num",          limit: 4
    t.integer  "restricting_num",    limit: 4
    t.decimal  "price",                          precision: 12, scale: 2, default: 0.0
    t.decimal  "old_price",                      precision: 12, scale: 2, default: 0.0
    t.integer  "category_id",        limit: 4
    t.integer  "sub_category_id",    limit: 4
    t.integer  "hot_category_id",    limit: 4
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.integer  "detail_category_id", limit: 4
    t.integer  "sale_count",         limit: 4,                            default: 0
    t.string   "desc",               limit: 255
    t.string   "info",               limit: 255
    t.string   "spec",               limit: 255
    t.string   "unit_price",         limit: 255
    t.string   "origin",             limit: 255
    t.string   "remark",             limit: 255
    t.string   "unique_id",          limit: 255
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["detail_category_id"], name: "index_products_on_detail_category_id", using: :btree
  add_index "products", ["hot_category_id"], name: "index_products_on_hot_category_id", using: :btree
  add_index "products", ["sort"], name: "index_products_on_sort", using: :btree
  add_index "products", ["sub_category_id"], name: "index_products_on_sub_category_id", using: :btree
  add_index "products", ["unit_id"], name: "index_products_on_unit_id", using: :btree

  create_table "promoters", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "phone",      limit: 255
    t.string   "id_card",    limit: 255
    t.integer  "sex",        limit: 1,   default: 0, null: false
    t.string   "material",   limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "promoters", ["name"], name: "index_promoters_on_name", using: :btree

  create_table "sub_categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "sort",        limit: 4,   default: 1, null: false
    t.string   "desc",        limit: 255
    t.integer  "category_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "unique_id",   limit: 255
  end

  add_index "sub_categories", ["category_id"], name: "index_sub_categories_on_category_id", using: :btree
  add_index "sub_categories", ["sort"], name: "index_sub_categories_on_sort", using: :btree

  create_table "system_settings", force: :cascade do |t|
    t.decimal  "delivery_price", precision: 12, scale: 2, default: 0.0
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "units", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "user_id",        limit: 255
    t.string   "client_type",    limit: 255
    t.string   "client_id",      limit: 255
    t.string   "user_name",      limit: 255
    t.string   "head_portrait",  limit: 255
    t.integer  "identification", limit: 4,   default: 0
    t.string   "password",       limit: 255
    t.string   "token",          limit: 255
    t.string   "phone_num",      limit: 255
    t.string   "phone",          limit: 255
    t.string   "rand",           limit: 255
    t.integer  "promoter_id",    limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "address_id",     limit: 4
    t.datetime "register_time"
    t.string   "unique_id",      limit: 255
  end

  add_index "users", ["address_id"], name: "index_users_on_address_id", using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", using: :btree
  add_index "users", ["promoter_id"], name: "index_users_on_promoter_id", using: :btree

  add_foreign_key "addresses", "users"
  add_foreign_key "adverts", "products"
  add_foreign_key "detail_categories", "sub_categories"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "hot_categories"
  add_foreign_key "products", "sub_categories"
  add_foreign_key "sub_categories", "categories"
end
