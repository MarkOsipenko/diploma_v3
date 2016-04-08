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

ActiveRecord::Schema.define(version: 20160408175915) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree

  create_table "page_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "url"
    t.string   "name"
  end

  add_index "page_links", ["name"], name: "index_page_links_on_name", using: :btree
  add_index "page_links", ["url"], name: "index_page_links_on_url", using: :btree

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "url"
    t.text     "body"
    t.integer  "translate"
  end

  add_index "pages", ["url"], name: "index_pages_on_url", using: :btree

  create_table "pages_categories", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "page_id"
    t.integer  "category_id"
  end

  create_table "pages_page_links", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "page_id"
    t.integer  "page_link_id"
  end

  create_table "words", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "page_id"
    t.text     "content"
    t.string   "definition"
  end

  add_index "words", ["definition"], name: "index_words_on_definition", using: :btree

end
