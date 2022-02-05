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

ActiveRecord::Schema.define(version: 2022_02_05_163610) do

  create_table "comments", force: :cascade do |t|
    t.string "commenter"
    t.text "body"
    t.integer "article_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tweets", force: :cascade do |t|
    t.integer "twitter_user_id", null: false
    t.string "full_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["twitter_user_id"], name: "index_tweets_on_twitter_user_id"
  end

  create_table "twitter_users", force: :cascade do |t|
    t.string "twitter_id"
    t.string "name"
    t.string "location"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "id_str"
    t.string "description"
  end

  create_table "wordle_tweets", force: :cascade do |t|
    t.string "wordle_type"
    t.integer "tweet_id", null: false
    t.integer "score"
    t.date "wordle_date"
    t.integer "wordle_incremental_day"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "import_version"
    t.string "import_notes"
    t.string "internal_stuff"
    t.integer "max_tries"
    t.index ["tweet_id"], name: "index_wordle_tweets_on_tweet_id"
  end

  add_foreign_key "comments", "articles"
  add_foreign_key "tweets", "twitter_users"
  add_foreign_key "wordle_tweets", "tweets"
end
