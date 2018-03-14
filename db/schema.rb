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

ActiveRecord::Schema.define(version: 20180216154056) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.date "date"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "user_id"
    t.integer "leader_id"
    t.datetime "follow_date"
    t.index ["leader_id"], name: "index_follows_on_leader_id"
  end

  create_table "hashtag_tweets", force: :cascade do |t|
    t.integer "hashtag_id"
    t.integer "tweet_id"
  end

  create_table "hashtags", force: :cascade do |t|
    t.string "tag"
  end

  create_table "mentions", force: :cascade do |t|
    t.string "username"
    t.integer "tweet_id"
  end

  create_table "persons", force: :cascade do |t|
    t.string "name"
    t.date "bday"
    t.string "sex"
    t.string "zipcode"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "message"
    t.string "username"
    t.date "timestamp"
  end

  create_table "users", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "username"
    t.text "email"
    t.string "password"
    t.integer "Number_of_followers"
    t.integer "Number_of_leaders"
  end

end
