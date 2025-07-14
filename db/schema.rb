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

ActiveRecord::Schema[8.0].define(version: 2025_07_14_193904) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "content"
    t.datetime "publish_at"
    t.string "author_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_image_url"
  end

  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "bio"
    t.string "avatar_url"
    t.string "position"
    t.string "email"
    t.jsonb "social_links", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_authors_on_name"
    t.index ["slug"], name: "index_authors_on_slug", unique: true
  end

  create_table "authorships", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "authorable_type", null: false
    t.bigint "authorable_id", null: false
    t.string "role", default: "primary"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id", "authorable_type"], name: "index_authorships_on_author_id_and_authorable_type"
    t.index ["author_id"], name: "index_authorships_on_author_id"
    t.index ["authorable_type", "authorable_id"], name: "index_authorships_on_authorable"
    t.index ["authorable_type", "authorable_id"], name: "index_authorships_on_authorable_type_and_authorable_id"
    t.index ["position"], name: "index_authorships_on_position"
  end

  create_table "content_blocks", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "url_pattern", null: false
    t.string "match_type", default: "exact", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_content_blocks_on_active"
    t.index ["url_pattern"], name: "index_content_blocks_on_url_pattern"
  end

  create_table "faqs", force: :cascade do |t|
    t.string "question"
    t.text "answer"
    t.string "slug"
    t.string "category"
    t.string "meta_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_faqs_on_category"
    t.index ["slug"], name: "index_faqs_on_slug", unique: true
  end

  create_table "institutions", primary_key: "institution_id", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "country_codes", default: [], array: true
    t.string "products", default: [], array: true
    t.string "logo_url"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "oauth"
    t.string "primary_color"
    t.index ["country_codes"], name: "index_institutions_on_country_codes", using: :gin
    t.index ["name"], name: "index_institutions_on_name"
    t.index ["products"], name: "index_institutions_on_products", using: :gin
  end

  create_table "redirects", force: :cascade do |t|
    t.string "source_path", null: false
    t.string "destination_path", null: false
    t.string "redirect_type", default: "permanent", null: false
    t.string "pattern_type", default: "exact", null: false
    t.boolean "active", default: true
    t.integer "priority", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "priority"], name: "index_redirects_on_active_and_priority"
    t.index ["source_path"], name: "index_redirects_on_source_path", unique: true
  end

  create_table "stock_prices", force: :cascade do |t|
    t.string "ticker"
    t.float "price"
    t.integer "month"
    t.integer "year"
    t.string "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticker"], name: "index_stock_prices_on_ticker"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.string "legal_name"
    t.jsonb "links", default: {}
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_image_url"
    t.virtual "search_vector", type: :tsvector, as: "(setweight(to_tsvector('simple'::regconfig, (COALESCE(symbol, ''::character varying))::text), 'B'::\"char\") || to_tsvector('simple'::regconfig, (COALESCE(name, ''::character varying))::text))", stored: true
    t.string "exchange"
    t.string "mic_code"
    t.string "country_code"
    t.string "kind"
    t.string "industry"
    t.string "sector"
    t.index ["country_code"], name: "index_stocks_on_country_code"
    t.index ["exchange"], name: "index_stocks_on_exchange"
    t.index ["kind"], name: "index_stocks_on_kind"
    t.index ["mic_code"], name: "index_stocks_on_mic_code"
    t.index ["search_vector"], name: "index_stocks_on_search_vector", using: :gin
    t.index ["symbol", "mic_code"], name: "index_stocks_on_symbol_and_mic_code", unique: true
  end

  create_table "terms", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "content"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video_id"
    t.string "video_title"
    t.text "video_description"
    t.string "video_thumbnail_url"
    t.date "video_upload_date"
    t.string "video_duration"
    t.string "meta_image_url"
  end

  create_table "tools", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "intro"
    t.text "description"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_slug"
    t.string "icon"
    t.string "meta_image_url"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "confirmed_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "authorships", "authors"
end
