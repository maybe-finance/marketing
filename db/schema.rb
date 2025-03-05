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

ActiveRecord::Schema[8.0].define(version: 2023_10_15_200034) do
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
end
