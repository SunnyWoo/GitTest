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

ActiveRecord::Schema.define(version: 20161007055921) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "adjustments", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "adjustable_id"
    t.string   "adjustable_type", limit: 255
    t.integer  "source_id"
    t.string   "source_type",     limit: 255
    t.float    "value",                                   null: false
    t.string   "description",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target"
    t.integer  "event",                                   null: false
    t.integer  "quantity",                    default: 1, null: false
  end

  add_index "adjustments", ["adjustable_id", "adjustable_type"], name: "index_adjustments_on_adjustable_id_and_adjustable_type", using: :btree
  add_index "adjustments", ["order_id"], name: "index_adjustments_on_order_id", using: :btree
  add_index "adjustments", ["source_id", "source_type"], name: "index_adjustments_on_source_id_and_source_type", using: :btree

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "failed_attempts",                    default: 0,  null: false
    t.datetime "locked_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "announcement_translations", force: :cascade do |t|
    t.integer  "announcement_id",             null: false
    t.string   "locale",          limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  add_index "announcement_translations", ["announcement_id"], name: "index_announcement_translations_on_announcement_id", using: :btree
  add_index "announcement_translations", ["locale"], name: "index_announcement_translations_on_locale", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.text     "message"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archived_artworks", force: :cascade do |t|
    t.integer  "original_artwork_id"
    t.integer  "model_id"
    t.integer  "user_id"
    t.string   "user_type",           limit: 255
    t.string   "name",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "application_id"
  end

  add_index "archived_artworks", ["model_id"], name: "index_archived_artworks_on_model_id", using: :btree
  add_index "archived_artworks", ["original_artwork_id"], name: "index_archived_artworks_on_original_artwork_id", using: :btree
  add_index "archived_artworks", ["user_id", "user_type"], name: "index_archived_artworks_on_user_id_and_user_type", using: :btree

  create_table "archived_layers", force: :cascade do |t|
    t.integer  "work_id"
    t.string   "layer_type",     limit: 255
    t.float    "orientation",                default: 0.0
    t.float    "scale_x",                    default: 1.0
    t.float    "scale_y",                    default: 1.0
    t.string   "color",          limit: 255
    t.float    "transparent",                default: 1.0
    t.string   "font_name",      limit: 255
    t.text     "font_text"
    t.string   "image",          limit: 255
    t.string   "filter",         limit: 255
    t.string   "filtered_image", limit: 255
    t.string   "material_name",  limit: 255
    t.float    "position_x",                 default: 0.0
    t.float    "position_y",                 default: 0.0
    t.float    "text_spacing_x",             default: 0.0
    t.float    "text_spacing_y",             default: 0.0
    t.string   "text_alignment", limit: 255
    t.integer  "position"
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",                   default: false, null: false
    t.integer  "mask_id"
  end

  add_index "archived_layers", ["mask_id"], name: "index_archived_layers_on_mask_id", using: :btree
  add_index "archived_layers", ["work_id"], name: "index_archived_layers_on_work_id", using: :btree

  create_table "archived_standardized_works", force: :cascade do |t|
    t.string   "uuid",             limit: 255
    t.string   "slug",             limit: 255
    t.integer  "original_work_id"
    t.integer  "user_id"
    t.string   "user_type",        limit: 255
    t.integer  "model_id"
    t.string   "name",             limit: 255
    t.integer  "price_tier_id"
    t.boolean  "featured"
    t.string   "print_image",      limit: 255
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "product_code",     limit: 255
    t.integer  "variant_id"
  end

  add_index "archived_standardized_works", ["model_id"], name: "index_archived_standardized_works_on_model_id", using: :btree
  add_index "archived_standardized_works", ["original_work_id"], name: "index_archived_standardized_works_on_original_work_id", using: :btree
  add_index "archived_standardized_works", ["price_tier_id"], name: "index_archived_standardized_works_on_price_tier_id", using: :btree
  add_index "archived_standardized_works", ["slug"], name: "index_archived_standardized_works_on_slug", unique: true, using: :btree
  add_index "archived_standardized_works", ["user_id", "user_type"], name: "index_archived_standardized_works_on_user_id_and_user_type", using: :btree
  add_index "archived_standardized_works", ["variant_id"], name: "index_archived_standardized_works_on_variant_id", using: :btree

  create_table "archived_works", force: :cascade do |t|
    t.integer  "original_work_id"
    t.integer  "artwork_id"
    t.integer  "model_id"
    t.string   "cover_image",         limit: 255
    t.string   "print_image",         limit: 255
    t.string   "fixed_image",         limit: 255
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                limit: 255
    t.string   "uuid",                limit: 255
    t.string   "ai",                  limit: 255
    t.string   "pdf",                 limit: 255
    t.json     "prices"
    t.string   "user_type",           limit: 255
    t.integer  "user_id"
    t.integer  "application_id"
    t.string   "name",                limit: 255
    t.string   "product_code",        limit: 255
    t.integer  "product_template_id"
    t.integer  "variant_id"
  end

  add_index "archived_works", ["artwork_id"], name: "index_archived_works_on_artwork_id", using: :btree
  add_index "archived_works", ["model_id"], name: "index_archived_works_on_model_id", using: :btree
  add_index "archived_works", ["original_work_id"], name: "index_archived_works_on_original_work_id", using: :btree
  add_index "archived_works", ["product_template_id"], name: "index_archived_works_on_product_template_id", using: :btree
  add_index "archived_works", ["variant_id"], name: "index_archived_works_on_variant_id", using: :btree

  create_table "areas", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artworks", force: :cascade do |t|
    t.integer  "model_id"
    t.string   "uuid",           limit: 255
    t.string   "name",           limit: 255
    t.text     "description"
    t.integer  "work_type"
    t.boolean  "finished",                   default: false
    t.boolean  "featured",                   default: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "user_type",      limit: 255
    t.integer  "application_id"
  end

  add_index "artworks", ["model_id"], name: "index_artworks_on_model_id", using: :btree
  add_index "artworks", ["user_id"], name: "index_artworks_on_user_id", using: :btree

  create_table "asset_package_categories", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.boolean  "available",                   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "packages_count",              default: 0
    t.integer  "downloads_count",             default: 0
  end

  add_index "asset_package_categories", ["downloads_count"], name: "index_asset_package_categories_on_downloads_count", using: :btree
  add_index "asset_package_categories", ["packages_count"], name: "index_asset_package_categories_on_packages_count", using: :btree

  create_table "asset_package_category_translations", force: :cascade do |t|
    t.integer  "asset_package_category_id",             null: false
    t.string   "locale",                    limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                      limit: 255
  end

  add_index "asset_package_category_translations", ["asset_package_category_id"], name: "index_84850a90fc4701144ebe68c1292fa8867be947eb", using: :btree
  add_index "asset_package_category_translations", ["locale"], name: "index_asset_package_category_translations_on_locale", using: :btree

  create_table "asset_package_collectings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "asset_package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_package_collectings", ["asset_package_id"], name: "index_asset_package_collectings_on_asset_package_id", using: :btree
  add_index "asset_package_collectings", ["user_id"], name: "index_asset_package_collectings_on_user_id", using: :btree

  create_table "asset_package_translations", force: :cascade do |t|
    t.integer  "asset_package_id",             null: false
    t.string   "locale",           limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             limit: 255
    t.text     "description"
  end

  add_index "asset_package_translations", ["asset_package_id"], name: "index_asset_package_translations_on_asset_package_id", using: :btree
  add_index "asset_package_translations", ["locale"], name: "index_asset_package_translations_on_locale", using: :btree

  create_table "asset_packages", force: :cascade do |t|
    t.integer  "designer_id"
    t.string   "icon",            limit: 255
    t.boolean  "available",                   default: false, null: false
    t.date     "begin_at"
    t.date     "end_at"
    t.string   "countries",       limit: 255, default: [],                 array: true
    t.integer  "position"
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "downloads_count",             default: 0
  end

  add_index "asset_packages", ["category_id"], name: "index_asset_packages_on_category_id", using: :btree
  add_index "asset_packages", ["designer_id"], name: "index_asset_packages_on_designer_id", using: :btree
  add_index "asset_packages", ["downloads_count"], name: "index_asset_packages_on_downloads_count", using: :btree

  create_table "assets", force: :cascade do |t|
    t.integer  "package_id"
    t.boolean  "available",               default: false, null: false
    t.string   "uuid",        limit: 255
    t.string   "type",        limit: 255
    t.string   "raster",      limit: 255
    t.string   "vector",      limit: 255
    t.json     "image_meta"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "colorizable",             default: false, null: false
  end

  add_index "assets", ["package_id"], name: "index_assets_on_package_id", using: :btree
  add_index "assets", ["uuid"], name: "index_assets_on_uuid", unique: true, using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "file",       limit: 255
    t.json     "file_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token",      limit: 255
    t.json     "extra_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_tokens", ["token"], name: "index_auth_tokens_on_token", unique: true, using: :btree
  add_index "auth_tokens", ["user_id"], name: "index_auth_tokens_on_user_id", using: :btree

  create_table "banners", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "image",      limit: 255
    t.text     "image_meta"
    t.date     "begin_on"
    t.date     "end_on"
    t.string   "countries",  limit: 255, default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "deeplink",   limit: 255
    t.string   "platforms",  limit: 255, default: [], array: true
    t.string   "url",        limit: 255
  end

  create_table "batch_flow_attachments", force: :cascade do |t|
    t.integer  "batch_flow_id",             null: false
    t.string   "name",          limit: 255, null: false
    t.string   "file",          limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batch_flow_attachments", ["batch_flow_id"], name: "index_batch_flow_attachments_on_batch_flow_id", using: :btree

  create_table "batch_flows", force: :cascade do |t|
    t.string   "aasm_state",        limit: 255
    t.integer  "factory_id"
    t.integer  "product_model_ids",             default: [], array: true
    t.integer  "print_item_ids",                default: [], array: true
    t.string   "batch_no",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deadline"
    t.string   "locale",            limit: 255
  end

  add_index "batch_flows", ["factory_id", "batch_no"], name: "index_batch_flows_on_factory_id_and_batch_no", unique: true, using: :btree
  add_index "batch_flows", ["factory_id"], name: "index_batch_flows_on_factory_id", using: :btree

  create_table "bdevent_images", force: :cascade do |t|
    t.integer  "bdevent_id"
    t.string   "locale",     limit: 255
    t.string   "file",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bdevent_images", ["bdevent_id"], name: "index_bdevent_images_on_bdevent_id", using: :btree

  create_table "bdevent_products", force: :cascade do |t|
    t.integer  "bdevent_id"
    t.integer  "product_id"
    t.string   "image",      limit: 255
    t.json     "info"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bdevent_products", ["bdevent_id"], name: "index_bdevent_products_on_bdevent_id", using: :btree
  add_index "bdevent_products", ["product_id"], name: "index_bdevent_products_on_product_id", using: :btree

  create_table "bdevent_redeems", force: :cascade do |t|
    t.string   "code",              limit: 255
    t.integer  "bdevent_id"
    t.integer  "parent_id"
    t.integer  "children_count",                default: 0
    t.integer  "usage_count",                   default: 0
    t.integer  "usage_count_limit",             default: -1
    t.integer  "product_model_ids",             default: [],   array: true
    t.integer  "order_ids",                     default: [],   array: true
    t.boolean  "is_enabled",                    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "work_ids",                      default: [],   array: true
  end

  add_index "bdevent_redeems", ["bdevent_id"], name: "index_bdevent_redeems_on_bdevent_id", using: :btree
  add_index "bdevent_redeems", ["code"], name: "index_bdevent_redeems_on_code", using: :btree
  add_index "bdevent_redeems", ["parent_id"], name: "index_bdevent_redeems_on_parent_id", using: :btree

  create_table "bdevent_translations", force: :cascade do |t|
    t.integer  "bdevent_id",                    null: false
    t.string   "locale",            limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",             limit: 255
    t.text     "desc"
    t.string   "banner",            limit: 255
    t.string   "coming_soon_image", limit: 255
    t.string   "ticker",            limit: 255
    t.string   "coupon_desc",       limit: 255
  end

  add_index "bdevent_translations", ["bdevent_id"], name: "index_bdevent_translations_on_bdevent_id", using: :btree
  add_index "bdevent_translations", ["locale"], name: "index_bdevent_translations_on_locale", using: :btree

  create_table "bdevent_works", force: :cascade do |t|
    t.integer  "bdevent_id"
    t.integer  "work_id"
    t.string   "work_type",  limit: 255
    t.json     "info"
    t.string   "image",      limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bdevent_works", ["bdevent_id"], name: "index_bdevent_works_on_bdevent_id", using: :btree
  add_index "bdevent_works", ["work_id", "work_type"], name: "index_bdevent_works_on_work_id_and_work_type", using: :btree

  create_table "bdevents", force: :cascade do |t|
    t.string   "uuid",       limit: 255
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "priority",               default: 1
    t.boolean  "is_enabled"
    t.integer  "event_type",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background", limit: 255
  end

  add_index "bdevents", ["event_type"], name: "index_bdevents_on_event_type", using: :btree
  add_index "bdevents", ["is_enabled"], name: "index_bdevents_on_is_enabled", using: :btree

  create_table "billing_profiles", force: :cascade do |t|
    t.text     "address"
    t.string   "city",          limit: 255
    t.string   "name",          limit: 255
    t.string   "phone",         limit: 255
    t.string   "state",         limit: 255
    t.string   "zip_code",      limit: 255
    t.string   "country",       limit: 255
    t.integer  "billable_id"
    t.string   "billable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country_code",  limit: 255
    t.integer  "shipping_way",              default: 0
    t.string   "email",         limit: 255
    t.string   "type",          limit: 255
    t.string   "address_name",  limit: 255
    t.hstore   "memo"
    t.integer  "province_id"
    t.json     "address_data"
  end

  add_index "billing_profiles", ["billable_id", "billable_type"], name: "index_billing_profiles_on_billable_id_and_billable_type", using: :btree

  create_table "campaign_images", force: :cascade do |t|
    t.integer  "campaign_id"
    t.string   "key",             limit: 255
    t.string   "file",            limit: 255
    t.string   "desc",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link",            limit: 255
    t.boolean  "open_in_new_tab",             default: false
  end

  add_index "campaign_images", ["campaign_id"], name: "index_campaign_images_on_campaign_id", using: :btree
  add_index "campaign_images", ["key"], name: "index_campaign_images_on_key", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "key",                limit: 255
    t.string   "title",              limit: 255
    t.string   "desc",               limit: 255
    t.string   "designer_username",  limit: 255
    t.string   "artworks_class",     limit: 255
    t.json     "wordings"
    t.text     "about_designer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aasm_state",         limit: 255, default: "is_closed"
    t.string   "google_calendar_id", limit: 255
  end

  add_index "campaigns", ["key"], name: "index_campaigns_on_key", using: :btree

  create_table "change_price_events", force: :cascade do |t|
    t.integer  "operator_id"
    t.integer  "target_ids",                default: [], array: true
    t.integer  "price_tier_id"
    t.string   "target_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aasm_state",    limit: 255
  end

  create_table "change_price_histories", force: :cascade do |t|
    t.integer  "change_price_event_id"
    t.integer  "changeable_id"
    t.string   "changeable_type",        limit: 255
    t.string   "price_type",             limit: 255
    t.integer  "original_price_tier_id"
    t.integer  "target_price_tier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "change_price_histories", ["change_price_event_id"], name: "index_change_price_histories_on_change_price_event_id", using: :btree
  add_index "change_price_histories", ["changeable_id", "changeable_type"], name: "by_changeable", using: :btree

  create_table "channel_codes", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collection_tags", force: :cascade do |t|
    t.integer  "collection_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collection_translations", force: :cascade do |t|
    t.integer  "collection_id",             null: false
    t.string   "locale",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text",          limit: 255
  end

  add_index "collection_translations", ["collection_id"], name: "index_collection_translations_on_collection_id", using: :btree
  add_index "collection_translations", ["locale"], name: "index_collection_translations_on_locale", using: :btree

  create_table "collection_works", force: :cascade do |t|
    t.integer  "collection_id"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_type",     limit: 255
    t.integer  "position"
  end

  create_table "collections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.text     "content"
    t.boolean  "is_admin",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_notices", force: :cascade do |t|
    t.integer  "coupon_id"
    t.string   "notice",     limit: 255
    t.boolean  "available"
    t.json     "platform"
    t.json     "region"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_rules", force: :cascade do |t|
    t.integer  "coupon_id"
    t.string   "condition",            limit: 255
    t.integer  "threshold_id"
    t.integer  "product_model_ids",                default: [], array: true
    t.integer  "designer_ids",                     default: [], array: true
    t.integer  "product_category_ids",             default: [], array: true
    t.text     "work_gids",                        default: [], array: true
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bdevent_id"
  end

  add_index "coupon_rules", ["coupon_id"], name: "index_coupon_rules_on_coupon_id", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "title",                    limit: 255
    t.string   "code",                     limit: 255
    t.date     "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price_tier_id"
    t.integer  "parent_id"
    t.integer  "children_count",                                               default: 0
    t.string   "discount_type",            limit: 255
    t.decimal  "percentage",                           precision: 8, scale: 2
    t.string   "condition",                limit: 255
    t.integer  "threshold_id"
    t.integer  "product_model_ids",                                            default: [],    array: true
    t.string   "apply_target",             limit: 255
    t.integer  "usage_count",                                                  default: 0
    t.integer  "usage_count_limit",                                            default: -1
    t.date     "begin_at"
    t.boolean  "is_enabled",                                                   default: true
    t.boolean  "auto_approve",                                                 default: false
    t.integer  "designer_ids",                                                 default: [],    array: true
    t.text     "work_gids",                                                    default: [],    array: true
    t.integer  "user_usage_count_limit",                                       default: -1
    t.string   "base_price_type",          limit: 255
    t.integer  "apply_count_limit"
    t.integer  "product_category_ids",                                         default: [],    array: true
    t.integer  "bdevent_id"
    t.hstore   "settings",                                                     default: {}
    t.boolean  "is_free_shipping",                                             default: false
    t.boolean  "is_not_include_promotion",                                     default: false
  end

  add_index "coupons", ["parent_id"], name: "index_coupons_on_parent_id", using: :btree
  add_index "coupons", ["price_tier_id"], name: "index_coupons_on_price_tier_id", using: :btree
  add_index "coupons", ["threshold_id"], name: "index_coupons_on_threshold_id", using: :btree

  create_table "cp_resources", force: :cascade do |t|
    t.integer  "version"
    t.string   "aasm_state"
    t.datetime "publish_at"
    t.json     "list_urls"
    t.string   "small_package"
    t.string   "large_package"
    t.json     "memo"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "code",             limit: 255
    t.float    "price"
    t.integer  "product_model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coupon_id"
    t.integer  "payable_id"
    t.string   "payable_type",     limit: 255
  end

  add_index "currencies", ["payable_id"], name: "index_currencies_on_payable_id", using: :btree
  add_index "currencies", ["payable_type"], name: "index_currencies_on_payable_type", using: :btree
  add_index "currencies", ["product_model_id"], name: "index_currencies_on_product_model_id", using: :btree

  create_table "currency_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "code",        limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rate",                    default: 1.0
    t.integer  "precision",               default: 0
  end

  create_table "daily_records", force: :cascade do |t|
    t.string   "type"
    t.json     "data"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "target_ids", default: [],              array: true
  end

  create_table "deliver_error_collections", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "workable_id"
    t.string   "workable_type",   limit: 255
    t.text     "cover_image_url"
    t.text     "print_image_url"
    t.json     "error_messages"
    t.string   "aasm_state",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_orders", force: :cascade do |t|
    t.integer  "model_id"
    t.string   "order_no",       limit: 255
    t.integer  "print_item_ids",             default: [], null: false, array: true
    t.string   "state",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designers", force: :cascade do |t|
    t.string   "username",               limit: 255, default: "", null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "display_name",           limit: 255
    t.string   "avatar",                 limit: 255
    t.text     "description"
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                   limit: 255
  end

  add_index "designers", ["email"], name: "index_designers_on_email", unique: true, using: :btree
  add_index "designers", ["reset_password_token"], name: "index_designers_on_reset_password_token", unique: true, using: :btree

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token",           limit: 255
    t.text     "detail"
    t.string   "os_version",      limit: 255
    t.integer  "device_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "endpoint_arn",    limit: 255
    t.string   "country_code",    limit: 255
    t.string   "timezone",        limit: 255
    t.boolean  "is_enabled",                  default: true
    t.string   "getui_client_id", limit: 255
    t.string   "idfa",            limit: 255
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "email_banners", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "file",       limit: 255
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "is_default",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "export_orders", force: :cascade do |t|
    t.string   "file",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "factories", force: :cascade do |t|
    t.string   "code",          limit: 255
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contact_email"
    t.string   "locale",        limit: 255
  end

  add_index "factories", ["code"], name: "index_factories_on_code", unique: true, using: :btree

  create_table "factory_members", force: :cascade do |t|
    t.string   "username",               limit: 255, default: "",   null: false
    t.string   "email",                  limit: 255, default: "",   null: false
    t.string   "encrypted_password",     limit: 255, default: "",   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "factory_id"
    t.boolean  "enabled",                            default: true
  end

  add_index "factory_members", ["email"], name: "index_factory_members_on_email", unique: true, using: :btree
  add_index "factory_members", ["factory_id"], name: "index_factory_members_on_factory_id", using: :btree
  add_index "factory_members", ["reset_password_token"], name: "index_factory_members_on_reset_password_token", unique: true, using: :btree
  add_index "factory_members", ["username"], name: "index_factory_members_on_username", unique: true, using: :btree

  create_table "fees", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_gateways", force: :cascade do |t|
    t.string   "type",         limit: 255
    t.integer  "factory_id"
    t.hstore   "connect_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "header_link_tag_translations", force: :cascade do |t|
    t.integer  "header_link_tag_id",             null: false
    t.string   "locale",             limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",              limit: 255
  end

  add_index "header_link_tag_translations", ["header_link_tag_id"], name: "index_header_link_tag_translations_on_header_link_tag_id", using: :btree
  add_index "header_link_tag_translations", ["locale"], name: "index_header_link_tag_translations_on_locale", using: :btree

  create_table "header_link_tags", force: :cascade do |t|
    t.integer  "header_link_id"
    t.string   "style",          limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "header_link_translations", force: :cascade do |t|
    t.integer  "header_link_id",             null: false
    t.string   "locale",         limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",          limit: 255
  end

  add_index "header_link_translations", ["header_link_id"], name: "index_header_link_translations_on_header_link_id", using: :btree
  add_index "header_link_translations", ["locale"], name: "index_header_link_translations_on_locale", using: :btree

  create_table "header_links", force: :cascade do |t|
    t.integer  "parent_id"
    t.string   "href",                  limit: 255
    t.string   "link_type",             limit: 255
    t.integer  "spec_id"
    t.integer  "position"
    t.boolean  "blank",                             default: false, null: false
    t.boolean  "dropdown",                          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row"
    t.boolean  "auto_generate_product",             default: false, null: false
  end

  create_table "home_block_item_translations", force: :cascade do |t|
    t.integer  "home_block_item_id",             null: false
    t.string   "locale",             limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",              limit: 255
    t.string   "subtitle",           limit: 255
    t.string   "pic",                limit: 255
  end

  add_index "home_block_item_translations", ["home_block_item_id"], name: "index_home_block_item_translations_on_home_block_item_id", using: :btree
  add_index "home_block_item_translations", ["locale"], name: "index_home_block_item_translations_on_locale", using: :btree

  create_table "home_block_items", force: :cascade do |t|
    t.integer  "block_id"
    t.string   "image",      limit: 255
    t.string   "href",       limit: 255
    t.json     "image_meta"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_block_items", ["block_id"], name: "index_home_block_items_on_block_id", using: :btree

  create_table "home_block_translations", force: :cascade do |t|
    t.integer  "home_block_id",             null: false
    t.string   "locale",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",         limit: 255
  end

  add_index "home_block_translations", ["home_block_id"], name: "index_home_block_translations_on_home_block_id", using: :btree
  add_index "home_block_translations", ["locale"], name: "index_home_block_translations_on_locale", using: :btree

  create_table "home_blocks", force: :cascade do |t|
    t.string   "template",   limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "home_link_translations", force: :cascade do |t|
    t.integer  "home_link_id",             null: false
    t.string   "locale",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",         limit: 255
  end

  add_index "home_link_translations", ["home_link_id"], name: "index_home_link_translations_on_home_link_id", using: :btree
  add_index "home_link_translations", ["locale"], name: "index_home_link_translations_on_locale", using: :btree

  create_table "home_links", force: :cascade do |t|
    t.string   "href",       limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "home_slide_translations", force: :cascade do |t|
    t.integer  "home_slide_id",             null: false
    t.string   "locale",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",         limit: 255
    t.string   "slide",         limit: 255
  end

  add_index "home_slide_translations", ["home_slide_id"], name: "index_home_slide_translations_on_home_slide_id", using: :btree
  add_index "home_slide_translations", ["locale"], name: "index_home_slide_translations_on_locale", using: :btree

  create_table "home_slides", force: :cascade do |t|
    t.string   "slide",      limit: 255
    t.boolean  "is_enabled",             default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.string   "link",       limit: 255
    t.integer  "template",               default: 0
    t.hstore   "desc"
    t.string   "background", limit: 255
    t.integer  "priority",               default: 1
    t.string   "set",        limit: 255
  end

  create_table "import_order_succeeds", force: :cascade do |t|
    t.integer  "import_order_id"
    t.integer  "order_id"
    t.string   "guanyi_trade_code",    limit: 255
    t.string   "guanyi_platform_code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "import_order_succeeds", ["guanyi_trade_code"], name: "index_import_order_succeeds_on_guanyi_trade_code", unique: true, using: :btree
  add_index "import_order_succeeds", ["import_order_id"], name: "index_import_order_succeeds_on_import_order_id", using: :btree

  create_table "import_orders", force: :cascade do |t|
    t.string   "file",       limit: 255
    t.string   "aasm_state", limit: 255
    t.json     "failed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "impositions", force: :cascade do |t|
    t.integer  "model_id"
    t.float    "paper_width"
    t.float    "paper_height"
    t.json     "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sample",                   limit: 255
    t.integer  "rotate"
    t.string   "type",                     limit: 255
    t.string   "template",                 limit: 255
    t.boolean  "demo",                                 default: false, null: false
    t.string   "file",                     limit: 255
    t.boolean  "flip",                                 default: false
    t.boolean  "flop",                                 default: false
    t.boolean  "include_order_no_barcode",             default: false
  end

  add_index "impositions", ["id", "type"], name: "index_impositions_on_id_and_type", using: :btree
  add_index "impositions", ["model_id"], name: "index_impositions_on_model_id", using: :btree

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type", limit: 255
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name",     limit: 255
    t.string   "action_name",         limit: 255
    t.string   "view_name",           limit: 255
    t.string   "request_hash",        limit: 255
    t.string   "ip_address",          limit: 255
    t.string   "session_hash",        limit: 255
    t.string   "locale",              limit: 255
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "locale"], name: "poly_locale_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "layers", force: :cascade do |t|
    t.integer  "work_id"
    t.float    "orientation",                            default: 0.0
    t.float    "scale_x",                                default: 1.0
    t.float    "scale_y",                                default: 1.0
    t.string   "color",                      limit: 255
    t.float    "transparent",                            default: 1.0
    t.string   "font_name",                  limit: 255
    t.text     "font_text"
    t.string   "image",                      limit: 255
    t.string   "material_name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layer_type"
    t.string   "layer_no",                   limit: 255
    t.float    "position_x",                             default: 0.0
    t.float    "position_y",                             default: 0.0
    t.integer  "text_spacing_x"
    t.integer  "text_spacing_y"
    t.string   "text_alignment",             limit: 255
    t.integer  "filter_type"
    t.integer  "position"
    t.string   "filter",                     limit: 255, default: "0"
    t.string   "filtered_image",             limit: 255
    t.string   "uuid",                       limit: 255
    t.text     "image_meta"
    t.boolean  "disabled",                               default: false, null: false
    t.integer  "attached_image_id"
    t.integer  "attached_filtered_image_id"
    t.integer  "mask_id"
  end

  add_index "layers", ["attached_filtered_image_id"], name: "index_layers_on_attached_filtered_image_id", using: :btree
  add_index "layers", ["attached_image_id"], name: "index_layers_on_attached_image_id", using: :btree
  add_index "layers", ["layer_type"], name: "index_layers_on_layer_type", using: :btree
  add_index "layers", ["uuid"], name: "index_layers_on_uuid", unique: true, using: :btree
  add_index "layers", ["work_id"], name: "index_layers_on_work_id", using: :btree

  create_table "logcraft_activities", force: :cascade do |t|
    t.string   "key",            limit: 255
    t.integer  "trackable_id"
    t.string   "trackable_type", limit: 255
    t.integer  "user_id"
    t.string   "user_type",      limit: 255
    t.json     "source"
    t.text     "message"
    t.json     "extra_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logcraft_activities", ["trackable_id", "trackable_type"], name: "index_logcraft_activities_on_trackable_id_and_trackable_type", using: :btree
  add_index "logcraft_activities", ["user_id", "user_type"], name: "index_logcraft_activities_on_user_id_and_user_type", using: :btree

  create_table "logistics_suppliers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "mailgun_campaigns", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "campaign_id",       limit: 255
    t.boolean  "is_mailgun_create",             default: false
    t.json     "report"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "masks", force: :cascade do |t|
    t.string   "material_name", limit: 255
    t.string   "image",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "image_meta"
  end

  add_index "masks", ["material_name"], name: "index_masks_on_material_name", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",      limit: 255
    t.text     "body"
    t.string   "mail_to",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_no",   limit: 255
  end

  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "mobile_campaign_translations", force: :cascade do |t|
    t.integer  "mobile_campaign_id",             null: false
    t.string   "locale",             limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kv",                 limit: 255
    t.string   "title",              limit: 255
    t.string   "desc_short",         limit: 255
    t.string   "ticker",             limit: 255
  end

  add_index "mobile_campaign_translations", ["locale"], name: "index_mobile_campaign_translations_on_locale", using: :btree
  add_index "mobile_campaign_translations", ["mobile_campaign_id"], name: "index_mobile_campaign_translations_on_mobile_campaign_id", using: :btree

  create_table "mobile_campaigns", force: :cascade do |t|
    t.string   "kv",            limit: 255
    t.string   "title",         limit: 255
    t.string   "desc_short",    limit: 255
    t.string   "ticker",        limit: 255
    t.string   "campaign_type", limit: 255
    t.datetime "publish_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "is_enabled",                default: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mobile_components", force: :cascade do |t|
    t.integer  "mobile_page_id"
    t.string   "key",            limit: 255
    t.integer  "parent_id"
    t.integer  "position"
    t.string   "image",          limit: 255
    t.json     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_components", ["mobile_page_id"], name: "index_mobile_components_on_mobile_page_id", using: :btree
  add_index "mobile_components", ["parent_id"], name: "index_mobile_components_on_parent_id", using: :btree

  create_table "mobile_page_previews", force: :cascade do |t|
    t.integer  "mobile_page_id"
    t.string   "key"
    t.string   "title"
    t.string   "country_code"
    t.datetime "begin_at"
    t.datetime "close_at"
    t.integer  "page_type"
    t.json     "contents",       default: {}
    t.boolean  "is_enabled"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "mobile_pages", force: :cascade do |t|
    t.string   "key",          limit: 255
    t.string   "title",        limit: 255
    t.datetime "begin_at"
    t.datetime "close_at"
    t.boolean  "is_enabled",               default: false
    t.json     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_type"
    t.string   "country_code", limit: 255
  end

  add_index "mobile_pages", ["page_type"], name: "index_mobile_pages_on_page_type", using: :btree

  create_table "mobile_uis", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "description", limit: 255
    t.string   "template",    limit: 255
    t.string   "image",       limit: 255
    t.integer  "priority",                default: 1
    t.date     "start_at"
    t.date     "end_at"
    t.boolean  "is_enabled",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default",                 default: false
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.string   "locale",       limit: 255
    t.boolean  "is_enabled",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country_code", limit: 255
  end

  add_index "newsletter_subscriptions", ["email", "is_enabled"], name: "index_newsletter_subscriptions_on_email_and_is_enabled", using: :btree
  add_index "newsletter_subscriptions", ["email"], name: "index_newsletter_subscriptions_on_email", unique: true, using: :btree

  create_table "newsletters", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.datetime "delivery_at"
    t.json     "filter"
    t.string   "subject",             limit: 255
    t.text     "content"
    t.string   "locale",              limit: 255
    t.integer  "mailgun_campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state",                           default: 0
  end

  create_table "notes", force: :cascade do |t|
    t.text     "message"
    t.integer  "user_id"
    t.integer  "noteable_id"
    t.string   "noteable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",     limit: 255
  end

  create_table "notification_trackings", force: :cascade do |t|
    t.integer  "notification_id"
    t.integer  "user_id"
    t.string   "device_token",    limit: 255
    t.string   "country_code",    limit: 255
    t.datetime "opened_at"
    t.hstore   "extra_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_trackings", ["notification_id"], name: "index_notification_trackings_on_notification_id", using: :btree
  add_index "notification_trackings", ["user_id"], name: "index_notification_trackings_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "message",                      limit: 255
    t.string   "message_id",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "filter"
    t.datetime "delivery_at"
    t.string   "deep_link",                    limit: 255
    t.string   "jid",                          limit: 255
    t.integer  "filter_count"
    t.integer  "notification_trackings_count",             default: 0
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id",             null: false
    t.integer  "application_id",                null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",                    null: false
    t.text     "redirect_uri",                  null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,              null: false
    t.string   "uid",          limit: 255,              null: false
    t.string   "secret",       limit: 255,              null: false
    t.text     "redirect_uri",                          null: false
    t.string   "scopes",       limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "omniauths", force: :cascade do |t|
    t.string   "provider",         limit: 255
    t.string   "uid",              limit: 255
    t.text     "oauth_token"
    t.datetime "oauth_expires_at"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",            limit: 255
    t.string   "username",         limit: 255
    t.string   "owner_type",       limit: 255
    t.string   "oauth_secret",     limit: 255
  end

  add_index "omniauths", ["owner_id"], name: "index_omniauths_on_owner_id", using: :btree

  create_table "option_types", force: :cascade do |t|
    t.string   "name"
    t.string   "presentation"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "option_value_variants", force: :cascade do |t|
    t.integer  "variant_id"
    t.integer  "option_value_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "option_value_variants", ["variant_id", "option_value_id"], name: "index_option_value_variants_on_variant_id_and_option_value_id", unique: true, using: :btree
  add_index "option_value_variants", ["variant_id"], name: "index_option_value_variants_on_variant_id", using: :btree

  create_table "option_values", force: :cascade do |t|
    t.integer  "option_type_id"
    t.string   "name"
    t.string   "presentation"
    t.integer  "position"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "option_values", ["option_type_id", "name"], name: "index_option_values_on_option_type_id_and_name", unique: true, using: :btree
  add_index "option_values", ["option_type_id"], name: "index_option_values_on_option_type_id", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "itemable_id"
    t.string   "itemable_type",    limit: 255
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timestamp_no",     limit: 8
    t.datetime "print_at"
    t.string   "aasm_state",       limit: 255
    t.string   "pdf",              limit: 255
    t.json     "prices"
    t.json     "original_prices"
    t.integer  "remote_id"
    t.boolean  "delivered",                                            default: false
    t.boolean  "deliver_complete",                                     default: false
    t.json     "remote_info"
    t.decimal  "discount",                     precision: 8, scale: 2
    t.json     "selling_prices"
  end

  add_index "order_items", ["itemable_id", "itemable_type"], name: "index_order_items_on_itemable_id_and_itemable_type", using: :btree
  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["timestamp_no"], name: "index_order_items_on_timestamp_no", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "aasm_state",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price"
    t.string   "currency",              limit: 255
    t.string   "payment_id",            limit: 255
    t.string   "order_no",              limit: 255
    t.integer  "work_state",                                                default: 0
    t.string   "refund_id",             limit: 255
    t.string   "ship_code",             limit: 255
    t.string   "uuid",                  limit: 255
    t.integer  "coupon_id"
    t.string   "payment",               limit: 255
    t.hstore   "order_data"
    t.json     "payment_info",                                              default: {}
    t.boolean  "approved",                                                  default: false
    t.integer  "invoice_state",                                             default: 0
    t.json     "invoice_info"
    t.json     "embedded_coupon"
    t.decimal  "subtotal",                          precision: 8, scale: 2
    t.decimal  "discount",                          precision: 8, scale: 2
    t.decimal  "shipping_fee",                      precision: 8, scale: 2
    t.string   "shipping_receipt",      limit: 255
    t.integer  "application_id"
    t.text     "message"
    t.datetime "shipped_at"
    t.boolean  "viewable",                                                  default: true
    t.datetime "paid_at"
    t.integer  "remote_id"
    t.datetime "delivered_at"
    t.boolean  "deliver_complete",                                          default: false
    t.json     "remote_info"
    t.datetime "approved_at"
    t.integer  "merge_target_ids",                                          default: [],                 array: true
    t.integer  "packaging_state",                                           default: 0
    t.integer  "shipping_state",                                            default: 0
    t.decimal  "shipping_fee_discount",             precision: 8, scale: 2, default: 0.0
    t.integer  "flags"
    t.boolean  "watching",                                                  default: false
    t.boolean  "invoice_required"
    t.datetime "checked_out_at"
    t.integer  "lock_version",                                              default: 0,     null: false
    t.boolean  "enable_schedule",                                           default: true
    t.integer  "source",                                                    default: 0,     null: false
    t.string   "channel",               limit: 255
    t.json     "order_info"
  end

  add_index "orders", ["invoice_state"], name: "index_orders_on_invoice_state", using: :btree
  add_index "orders", ["order_data"], name: "index_orders_on_order_data", using: :gist
  add_index "orders", ["order_no"], name: "index_orders_on_order_no", using: :btree
  add_index "orders", ["remote_id"], name: "index_orders_on_remote_id", unique: true, using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["uuid"], name: "index_orders_on_uuid", using: :btree
  add_index "orders", ["work_state"], name: "index_orders_on_work_state", using: :btree

  create_table "packages", force: :cascade do |t|
    t.string   "aasm_state",            limit: 255
    t.string   "ship_code",             limit: 255
    t.datetime "shipped_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "package_no",            limit: 255
    t.integer  "logistics_supplier_id"
  end

  add_index "packages", ["package_no"], name: "index_packages_on_package_no", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id"
    t.string   "action",     limit: 255
    t.string   "resource",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "picking_materials", force: :cascade do |t|
    t.integer  "model_id"
    t.string   "material",   limit: 255
    t.integer  "quantity",               default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "picking_materials", ["model_id"], name: "index_picking_materials_on_model_id", using: :btree

  create_table "preview_composers", force: :cascade do |t|
    t.string   "type",        limit: 255
    t.integer  "model_id"
    t.text     "layers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",         limit: 255
    t.boolean  "available",               default: false, null: false
    t.integer  "position"
    t.integer  "template_id"
  end

  add_index "preview_composers", ["model_id", "key"], name: "index_preview_composers_on_model_id_and_key", using: :btree
  add_index "preview_composers", ["model_id"], name: "index_preview_composers_on_model_id", using: :btree
  add_index "preview_composers", ["template_id"], name: "index_preview_composers_on_template_id", using: :btree

  create_table "preview_samples", force: :cascade do |t|
    t.integer  "preview_composer_id"
    t.integer  "work_id"
    t.string   "result",              limit: 255
    t.text     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preview_samples", ["preview_composer_id"], name: "index_preview_samples_on_preview_composer_id", using: :btree
  add_index "preview_samples", ["work_id"], name: "index_preview_samples_on_work_id", using: :btree

  create_table "previews", force: :cascade do |t|
    t.integer  "work_id"
    t.string   "key",          limit: 255
    t.string   "image",        limit: 255
    t.text     "image_meta"
    t.boolean  "high_quality",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "work_type",    limit: 255
  end

  add_index "previews", ["work_id", "key"], name: "index_previews_on_work_id_and_key", using: :btree
  add_index "previews", ["work_id"], name: "index_previews_on_work_id", using: :btree

  create_table "price_tiers", force: :cascade do |t|
    t.integer  "tier"
    t.json     "prices"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description", limit: 255
  end

  create_table "print_histories", force: :cascade do |t|
    t.integer  "print_item_id"
    t.integer  "timestamp_no",  limit: 8
    t.string   "print_type",    limit: 255
    t.string   "reason",        limit: 255
    t.datetime "prepare_at"
    t.datetime "print_at"
    t.datetime "onboard_at"
    t.datetime "sublimated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "qualified_at"
    t.datetime "shipped_at"
  end

  create_table "print_items", force: :cascade do |t|
    t.integer  "order_item_id"
    t.integer  "timestamp_no",    limit: 8
    t.string   "aasm_state",      limit: 255
    t.datetime "print_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "model_id"
    t.datetime "prepare_at"
    t.datetime "sublimated_at"
    t.datetime "onboard_at"
    t.integer  "package_id"
    t.datetime "qualified_at"
    t.datetime "shipped_at"
    t.boolean  "enable_schedule",             default: true
  end

  add_index "print_items", ["model_id"], name: "index_print_items_on_model_id", using: :btree
  add_index "print_items", ["package_id"], name: "index_print_items_on_package_id", using: :btree
  add_index "print_items", ["timestamp_no"], name: "index_print_items_on_timestamp_no", using: :btree

  create_table "product_categories", force: :cascade do |t|
    t.string   "key",              limit: 255
    t.boolean  "available",                    default: false,                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "category_code_id", limit: 255
    t.string   "image",            limit: 255
    t.json     "positions",                    default: {"ios"=>1, "android"=>1, "website"=>1}
  end

  add_index "product_categories", ["key"], name: "index_product_categories_on_key", unique: true, using: :btree

  create_table "product_category_codes", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_category_codes", ["code"], name: "index_product_category_codes_on_code", unique: true, using: :btree

  create_table "product_category_translations", force: :cascade do |t|
    t.integer  "product_category_id",             null: false
    t.string   "locale",              limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                limit: 255
  end

  add_index "product_category_translations", ["locale"], name: "index_product_category_translations_on_locale", using: :btree
  add_index "product_category_translations", ["product_category_id"], name: "index_product_category_translations_on_product_category_id", using: :btree

  create_table "product_crafts", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_crafts", ["code"], name: "index_product_crafts_on_code", unique: true, using: :btree

  create_table "product_materials", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_materials", ["code"], name: "index_product_materials_on_code", unique: true, using: :btree

  create_table "product_model_description_images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "image",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_model_description_images", ["product_id"], name: "index_product_model_description_images_on_product_id", using: :btree

  create_table "product_model_translations", force: :cascade do |t|
    t.integer  "product_model_id",             null: false
    t.string   "locale",           limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             limit: 255
    t.text     "description"
    t.string   "short_name",       limit: 255
  end

  add_index "product_model_translations", ["locale"], name: "index_product_model_translations_on_locale", using: :btree
  add_index "product_model_translations", ["product_model_id"], name: "index_product_model_translations_on_product_model_id", using: :btree

  create_table "product_models", force: :cascade do |t|
    t.string   "name",                                      limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available",                                             default: false
    t.string   "slug",                                      limit: 255
    t.integer  "category_id"
    t.string   "key",                                       limit: 255
    t.string   "dir_name",                                  limit: 255
    t.string   "placeholder_image",                         limit: 255
    t.integer  "price_tier_id"
    t.json     "design_platform"
    t.json     "customize_platform"
    t.integer  "customized_special_price_tier_id"
    t.string   "material",                                  limit: 255
    t.float    "weight"
    t.boolean  "enable_white",                                          default: false
    t.boolean  "auto_imposite",                                         default: false,                                  null: false
    t.integer  "factory_id"
    t.json     "extra_info"
    t.string   "aasm_state",                                limit: 255
    t.json     "positions",                                             default: {"ios"=>1, "android"=>1, "website"=>1}
    t.string   "remote_key",                                limit: 255
    t.string   "print_image_mask",                          limit: 255
    t.string   "watermark",                                 limit: 255
    t.integer  "craft_id"
    t.integer  "spec_id"
    t.integer  "material_id"
    t.string   "code",                                      limit: 255
    t.string   "external_code",                             limit: 255
    t.boolean  "enable_composite_with_horizontal_rotation",             default: false
    t.boolean  "create_order_image_by_cover_image",                     default: false
    t.boolean  "enable_back_image",                                     default: false
    t.integer  "profit_id"
  end

  add_index "product_models", ["category_id"], name: "index_product_models_on_category_id", using: :btree
  add_index "product_models", ["customized_special_price_tier_id"], name: "index_product_models_on_customized_special_price_tier_id", using: :btree
  add_index "product_models", ["factory_id"], name: "index_product_models_on_factory_id", using: :btree
  add_index "product_models", ["key", "category_id"], name: "index_product_models_on_key_and_category_id", unique: true, using: :btree
  add_index "product_models", ["key"], name: "index_product_models_on_key", using: :btree
  add_index "product_models", ["price_tier_id"], name: "index_product_models_on_price_tier_id", using: :btree
  add_index "product_models", ["profit_id"], name: "index_product_models_on_profit_id", using: :btree
  add_index "product_models", ["slug"], name: "index_product_models_on_slug", unique: true, using: :btree

  create_table "product_option_types", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "option_type_id"
    t.integer  "position"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "product_option_types", ["product_id", "option_type_id"], name: "index_product_option_types_on_product_id_and_option_type_id", unique: true, using: :btree
  add_index "product_option_types", ["product_id"], name: "index_product_option_types_on_product_id", using: :btree

  create_table "product_specs", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_specs", ["code"], name: "index_product_specs_on_code", unique: true, using: :btree

  create_table "product_templates", force: :cascade do |t|
    t.integer  "product_model_id"
    t.integer  "store_id"
    t.integer  "price_tier_id"
    t.string   "name",                  limit: 255
    t.string   "placeholder_image",     limit: 255
    t.string   "template_image",        limit: 255
    t.integer  "template_type"
    t.string   "aasm_state",            limit: 255
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "image_meta"
    t.integer  "works_count",                       default: 0
    t.integer  "archived_works_count",              default: 0
    t.datetime "deleted_at"
    t.integer  "bought_count",                      default: 0
    t.integer  "special_price_tier_id"
    t.text     "description"
  end

  add_index "product_templates", ["bought_count"], name: "index_product_templates_on_bought_count", using: :btree
  add_index "product_templates", ["deleted_at"], name: "index_product_templates_on_deleted_at", using: :btree
  add_index "product_templates", ["price_tier_id"], name: "index_product_templates_on_price_tier_id", using: :btree
  add_index "product_templates", ["product_model_id"], name: "index_product_templates_on_product_model_id", using: :btree
  add_index "product_templates", ["special_price_tier_id"], name: "index_product_templates_on_special_price_tier_id", using: :btree
  add_index "product_templates", ["store_id"], name: "index_product_templates_on_store_id", using: :btree

  create_table "promotion_references", force: :cascade do |t|
    t.integer  "promotion_id"
    t.integer  "promotable_id"
    t.string   "promotable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price_tier_id"
  end

  add_index "promotion_references", ["promotable_id", "promotable_type"], name: "index_promotion_references_on_promotable_id_and_promotable_type", using: :btree
  add_index "promotion_references", ["promotion_id"], name: "index_promotion_references_on_promotion_id", using: :btree

  create_table "promotion_rules", force: :cascade do |t|
    t.integer  "promotion_id"
    t.string   "condition",            limit: 255
    t.integer  "threshold_id"
    t.integer  "product_model_ids",                default: [], array: true
    t.integer  "designer_ids",                     default: [], array: true
    t.integer  "product_category_ids",             default: [], array: true
    t.text     "work_gids",                        default: [], array: true
    t.integer  "bdevent_id"
    t.integer  "quantity",                         default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotion_rules", ["promotion_id"], name: "index_promotion_rules_on_promotion_id", using: :btree

  create_table "promotions", force: :cascade do |t|
    t.string   "name",            limit: 255, null: false
    t.text     "description"
    t.string   "type",            limit: 255, null: false
    t.integer  "aasm_state"
    t.integer  "rule"
    t.json     "rule_parameters"
    t.integer  "targets"
    t.datetime "begins_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level"
  end

  add_index "promotions", ["type", "aasm_state"], name: "index_promotions_on_type_and_aasm_state", using: :btree
  add_index "promotions", ["type"], name: "index_promotions_on_type", using: :btree

  create_table "provinces", force: :cascade do |t|
    t.integer  "area_id"
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",       limit: 2
  end

  add_index "provinces", ["area_id"], name: "index_provinces_on_area_id", using: :btree
  add_index "provinces", ["code"], name: "index_provinces_on_code", using: :btree

  create_table "purchase_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_durations", force: :cascade do |t|
    t.string   "year",       limit: 255
    t.string   "month",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_durations", ["year", "month"], name: "index_purchase_durations_on_year_and_month", unique: true, using: :btree

  create_table "purchase_histories", force: :cascade do |t|
    t.integer  "duration_id"
    t.integer  "product_id"
    t.string   "category_name", limit: 255
    t.integer  "b2c_count"
    t.float    "price"
    t.json     "price_tiers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_histories", ["duration_id"], name: "index_purchase_histories_on_duration_id", using: :btree

  create_table "purchase_price_tiers", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "count_key"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_price_tiers", ["category_id", "count_key"], name: "index_purchase_price_tiers_on_category_id_and_count_key", unique: true, using: :btree
  add_index "purchase_price_tiers", ["category_id"], name: "index_purchase_price_tiers_on_category_id", using: :btree
  add_index "purchase_price_tiers", ["count_key"], name: "index_purchase_price_tiers_on_count_key", using: :btree

  create_table "purchase_product_references", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "category_id"
    t.integer  "b2c_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_product_references", ["category_id"], name: "index_purchase_product_references_on_category_id", using: :btree
  add_index "purchase_product_references", ["product_id"], name: "index_purchase_product_references_on_product_id", using: :btree

  create_table "question_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_category_translations", force: :cascade do |t|
    t.integer  "question_category_id",             null: false
    t.string   "locale",               limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                 limit: 255
  end

  add_index "question_category_translations", ["locale"], name: "index_question_category_translations_on_locale", using: :btree
  add_index "question_category_translations", ["question_category_id"], name: "index_question_category_translations_on_question_category_id", using: :btree

  create_table "question_translations", force: :cascade do |t|
    t.integer  "question_id",             null: false
    t.string   "locale",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "question",    limit: 255
    t.text     "answer"
  end

  add_index "question_translations", ["locale"], name: "index_question_translations_on_locale", using: :btree
  add_index "question_translations", ["question_id"], name: "index_question_translations_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "question",             limit: 255
    t.text     "answer"
    t.integer  "question_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommend_sorts", force: :cascade do |t|
    t.string   "design_platform", limit: 255
    t.string   "sort",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "refunds", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "refund_no",  limit: 255
    t.float    "amount"
    t.string   "note",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.string   "user_role",             limit: 255
    t.integer  "order_item_num"
    t.integer  "price"
    t.integer  "coupon_price"
    t.integer  "shipping_fee"
    t.string   "country_code",          limit: 255
    t.string   "platform",              limit: 255
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subtotal"
    t.integer  "refund"
    t.integer  "total"
    t.integer  "shipping_fee_discount"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "work_id"
    t.string   "work_type",  limit: 255
    t.text     "body"
    t.integer  "star"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree
  add_index "reviews", ["work_id", "work_type"], name: "index_reviews_on_work_id_and_work_type", using: :btree

  create_table "rewards", force: :cascade do |t|
    t.string   "order_no",    null: false
    t.string   "phone",       null: false
    t.string   "coupon_code"
    t.string   "avatar"
    t.string   "cover"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "rewards", ["coupon_code"], name: "index_rewards_on_coupon_code", using: :btree
  add_index "rewards", ["order_no", "phone"], name: "index_rewards_on_order_no_and_phone", using: :btree

  create_table "role_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "type",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_role_groups", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "role_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduled_events", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "scheduled_at"
    t.boolean  "executed",                 default: false
    t.json     "extra_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduled_events", ["name"], name: "index_scheduled_events_on_name", unique: true, using: :btree

  create_table "shelf_categories", force: :cascade do |t|
    t.integer  "factory_id"
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "shelf_categories", ["factory_id"], name: "index_shelf_categories_on_factory_id", using: :btree
  add_index "shelf_categories", ["name", "factory_id"], name: "index_shelf_categories_on_name_and_factory_id", unique: true, using: :btree
  add_index "shelf_categories", ["name"], name: "index_shelf_categories_on_name", unique: true, using: :btree

  create_table "shelf_materials", force: :cascade do |t|
    t.integer  "factory_id"
    t.string   "name",                  limit: 255
    t.string   "serial",                limit: 255,             null: false
    t.string   "image",                 limit: 255
    t.integer  "quantity",                          default: 0, null: false
    t.integer  "safe_minimum_quantity",             default: 0
    t.integer  "scrapped_quantity",                 default: 0
    t.string   "aasm_state",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "shelf_materials", ["factory_id"], name: "index_shelf_materials_on_factory_id", using: :btree
  add_index "shelf_materials", ["serial", "factory_id"], name: "index_shelf_materials_on_serial_and_factory_id", unique: true, using: :btree
  add_index "shelf_materials", ["serial"], name: "index_shelf_materials_on_serial", unique: true, using: :btree

  create_table "shelves", force: :cascade do |t|
    t.string   "serial",                limit: 255
    t.string   "section",               limit: 255
    t.string   "name",                  limit: 255
    t.integer  "quantity",                          default: 0
    t.integer  "factory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "serial_name",           limit: 255
    t.integer  "safe_minimum_quantity",             default: 0
    t.integer  "material_id"
    t.integer  "category_id"
    t.datetime "deleted_at"
  end

  add_index "shelves", ["category_id"], name: "index_shelves_on_category_id", using: :btree
  add_index "shelves", ["material_id"], name: "index_shelves_on_material_id", using: :btree
  add_index "shelves", ["serial", "section", "factory_id"], name: "index_shelves_on_serial_and_section_and_factory_id", unique: true, using: :btree

  create_table "shipping_fees", force: :cascade do |t|
    t.string   "type",                  limit: 255
    t.integer  "province_id"
    t.integer  "logistics_supplier_id"
    t.string   "country",               limit: 255
    t.string   "currency",              limit: 255
    t.float    "weight"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_fees", ["type", "country", "weight"], name: "index_shipping_fees_on_type_and_country_and_weight", using: :btree
  add_index "shipping_fees", ["type", "province_id", "weight"], name: "index_shipping_fees_on_type_and_province_id_and_weight", using: :btree
  add_index "shipping_fees", ["type"], name: "index_shipping_fees_on_type", using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "site_settings", force: :cascade do |t|
    t.string   "key",         limit: 255
    t.text     "value"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_settings", ["key"], name: "index_site_settings_on_key", unique: true, using: :btree

  create_table "standardized_works", force: :cascade do |t|
    t.string   "uuid",              limit: 255
    t.integer  "user_id"
    t.string   "user_type",         limit: 255
    t.integer  "model_id"
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "aasm_state",        limit: 255
    t.integer  "price_tier_id"
    t.boolean  "featured",                      default: false, null: false
    t.string   "print_image",       limit: 255
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "impressions_count",             default: 0
    t.integer  "cradle",                        default: 0
    t.integer  "bought_count",                  default: 0
    t.text     "content"
    t.integer  "variant_id"
  end

  add_index "standardized_works", ["model_id"], name: "index_standardized_works_on_model_id", using: :btree
  add_index "standardized_works", ["price_tier_id"], name: "index_standardized_works_on_price_tier_id", using: :btree
  add_index "standardized_works", ["slug"], name: "index_standardized_works_on_slug", unique: true, using: :btree
  add_index "standardized_works", ["user_id", "user_type"], name: "index_standardized_works_on_user_id_and_user_type", using: :btree
  add_index "standardized_works", ["uuid"], name: "index_standardized_works_on_uuid", unique: true, using: :btree
  add_index "standardized_works", ["variant_id"], name: "index_standardized_works_on_variant_id", using: :btree

  create_table "store_components", force: :cascade do |t|
    t.integer  "store_id"
    t.string   "key",        limit: 255
    t.string   "image",      limit: 255
    t.integer  "position"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "store_components", ["store_id"], name: "index_store_components_on_store_id", using: :btree

  create_table "stores", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "name",                   limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                  limit: 255
    t.text     "description"
    t.string   "avatar",                 limit: 255
    t.string   "code",                   limit: 255
    t.string   "slug",                   limit: 255
    t.json     "tap_settings"
    t.string   "logo"
    t.string   "store_footer_img"
    t.hstore   "contact_info"
  end

  add_index "stores", ["email"], name: "index_stores_on_email", unique: true, using: :btree
  add_index "stores", ["reset_password_token"], name: "index_stores_on_reset_password_token", unique: true, using: :btree
  add_index "stores", ["slug"], name: "index_stores_on_slug", unique: true, using: :btree

  create_table "tag_translations", force: :cascade do |t|
    t.integer  "tag_id",                 null: false
    t.string   "locale",     limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text",       limit: 255
  end

  add_index "tag_translations", ["locale"], name: "index_tag_translations_on_locale", using: :btree
  add_index "tag_translations", ["tag_id"], name: "index_tag_translations_on_tag_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "taggable_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "taggable_type", limit: 255
    t.integer  "position"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "temp_shelves", force: :cascade do |t|
    t.integer  "print_item_id"
    t.string   "serial",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",   limit: 255
  end

  add_index "temp_shelves", ["print_item_id"], name: "index_temp_shelves_on_print_item_id", using: :btree

  create_table "timestamps", force: :cascade do |t|
    t.date     "date"
    t.integer  "timestamp_no", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "timestamps", ["date"], name: "index_timestamps_on_date", unique: true, using: :btree

  create_table "tinymce_images", force: :cascade do |t|
    t.string   "file",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", force: :cascade do |t|
    t.string   "locale",         limit: 255
    t.string   "key",            limit: 255
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_role_groups", force: :cascade do |t|
    t.integer  "role_group_id"
    t.integer  "user_id"
    t.string   "user_type",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_role_groups", ["user_id", "user_type"], name: "index_user_role_groups_on_user_id_and_user_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar",                 limit: 255
    t.integer  "role"
    t.hstore   "profile"
    t.integer  "gender"
    t.string   "background",             limit: 255
    t.json     "image_meta"
    t.string   "mobile",                 limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "mobile_country_code",    limit: 16
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["mobile", "mobile_country_code"], name: "index_users_on_mobile_and_mobile_country_code", unique: true, using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "variants", ["product_id"], name: "index_variants_on_product_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "waybill_routes", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "route_no",       limit: 255
    t.string   "mail_no",        limit: 255
    t.datetime "accept_time"
    t.string   "accept_address", limit: 255
    t.string   "remark",         limit: 255
    t.string   "op_code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "package_id"
  end

  add_index "waybill_routes", ["package_id"], name: "index_waybill_routes_on_package_id", using: :btree

  create_table "wishlist_items", force: :cascade do |t|
    t.integer  "wishlist_id"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wishlist_items", ["wishlist_id"], name: "index_wishlist_items_on_wishlist_id", using: :btree
  add_index "wishlist_items", ["work_id"], name: "index_wishlist_items_on_work_id", using: :btree

  create_table "wishlists", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wishlists", ["user_id"], name: "index_wishlists_on_user_id", using: :btree

  create_table "work_codes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_type",    limit: 255
    t.string   "work_type",    limit: 255
    t.integer  "work_id"
    t.string   "code",         limit: 255
    t.string   "product_code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "work_output_files", force: :cascade do |t|
    t.integer  "work_id"
    t.string   "work_type",  limit: 255
    t.string   "key",        limit: 255
    t.string   "file",       limit: 255
    t.json     "image_meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_output_files", ["work_id", "work_type"], name: "index_work_output_files_on_work_id_and_work_type", using: :btree

  create_table "work_sets", force: :cascade do |t|
    t.integer  "designer_id"
    t.integer  "model_id"
    t.integer  "work_ids",                        default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_filename",        limit: 255
    t.string   "zip_entry_filenames", limit: 255, default: [], array: true
    t.string   "designer_type",       limit: 255
  end

  add_index "work_sets", ["designer_id", "designer_type"], name: "index_work_sets_on_designer_id_and_designer_type", using: :btree
  add_index "work_sets", ["designer_id"], name: "index_work_sets_on_designer_id", using: :btree
  add_index "work_sets", ["model_id"], name: "index_work_sets_on_model_id", using: :btree

  create_table "work_specs", force: :cascade do |t|
    t.integer  "model_id"
    t.string   "name",                                      limit: 255
    t.text     "description"
    t.float    "width"
    t.float    "height"
    t.integer  "dpi",                                                                           default: 300
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_image",                          limit: 255
    t.string   "overlay_image",                             limit: 255
    t.string   "shape",                                     limit: 255
    t.string   "alignment_points",                          limit: 255
    t.decimal  "padding_top",                                           precision: 8, scale: 2, default: 0.0,     null: false
    t.decimal  "padding_right",                                         precision: 8, scale: 2, default: 0.0,     null: false
    t.decimal  "padding_bottom",                                        precision: 8, scale: 2, default: 0.0,     null: false
    t.decimal  "padding_left",                                          precision: 8, scale: 2, default: 0.0,     null: false
    t.string   "background_color",                          limit: 255,                         default: "white", null: false
    t.integer  "variant_id"
    t.string   "dir_name"
    t.string   "placeholder_image"
    t.boolean  "enable_white",                                                                  default: false
    t.boolean  "auto_imposite",                                                                 default: false
    t.string   "watermark"
    t.string   "print_image_mask"
    t.boolean  "enable_composite_with_horizontal_rotation",                                     default: false
    t.boolean  "create_order_image_by_cover_image",                                             default: false
    t.boolean  "enable_back_image",                                                             default: false
  end

  add_index "work_specs", ["model_id"], name: "index_work_specs_on_model_id", using: :btree
  add_index "work_specs", ["variant_id"], name: "index_work_specs_on_variant_id", unique: true, using: :btree

  create_table "work_templates", force: :cascade do |t|
    t.integer  "model_id"
    t.string   "background_image", limit: 255
    t.string   "overlay_image",    limit: 255
    t.string   "aasm_state",       limit: 255
    t.json     "masks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "works", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "description",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_image",             limit: 255
    t.integer  "work_type",                           default: 1
    t.boolean  "finished",                            default: false
    t.boolean  "feature",                             default: false
    t.string   "uuid",                    limit: 255
    t.string   "print_image",             limit: 255
    t.integer  "model_id"
    t.integer  "artwork_id"
    t.json     "image_meta"
    t.string   "slug",                    limit: 255
    t.integer  "impressions_count",                   default: 0
    t.string   "ai",                      limit: 255
    t.string   "pdf",                     limit: 255
    t.integer  "price_tier_id"
    t.integer  "attached_cover_image_id"
    t.integer  "template_id"
    t.datetime "deleted_at"
    t.string   "user_type",               limit: 255
    t.integer  "user_id"
    t.integer  "application_id"
    t.integer  "product_template_id"
    t.integer  "cradle",                              default: 0
    t.text     "share_text"
    t.integer  "variant_id"
  end

  add_index "works", ["artwork_id"], name: "index_works_on_artwork_id", using: :btree
  add_index "works", ["attached_cover_image_id"], name: "index_works_on_attached_cover_image_id", using: :btree
  add_index "works", ["deleted_at"], name: "index_works_on_deleted_at", using: :btree
  add_index "works", ["model_id"], name: "index_works_on_model_id", using: :btree
  add_index "works", ["price_tier_id"], name: "index_works_on_price_tier_id", using: :btree
  add_index "works", ["product_template_id"], name: "index_works_on_product_template_id", using: :btree
  add_index "works", ["slug"], name: "index_works_on_slug", unique: true, using: :btree
  add_index "works", ["uuid"], name: "index_works_on_uuid", unique: true, using: :btree
  add_index "works", ["variant_id"], name: "index_works_on_variant_id", using: :btree

end
