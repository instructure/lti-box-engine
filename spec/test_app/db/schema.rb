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

ActiveRecord::Schema.define(version: 20140604153946) do

  create_table "lti_box_engine_accounts", force: true do |t|
    t.string   "name"
    t.string   "oauth_key"
    t.string   "oauth_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lti_box_engine_lti_launches", force: true do |t|
    t.string   "nonce"
    t.text     "payload"
    t.datetime "request_oauth_timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.datetime "token_timestamp"
    t.integer  "user_id"
  end

  create_table "lti_box_engine_users", force: true do |t|
    t.string  "tool_consumer_instance_guid"
    t.string  "lti_user_id"
    t.integer "account_id"
    t.string  "encrypted_refresh_token"
    t.string  "encrypted_refresh_token_iv"
    t.string  "encrypted_refresh_token_salt"
    t.string  "encrypted_access_token"
    t.string  "encrypted_access_token_iv"
    t.string  "encrypted_access_token_salt"
  end

end
