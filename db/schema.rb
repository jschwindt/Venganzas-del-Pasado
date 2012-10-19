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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121019030410) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["slug"], :name => "index_articles_on_slug", :unique => true

  create_table "audios", :force => true do |t|
    t.integer "post_id"
    t.string  "url"
    t.integer "bytes"
  end

  add_index "audios", ["post_id"], :name => "index_audios_on_post_id"

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.string   "author"
    t.string   "author_email"
    t.string   "author_ip"
    t.text     "content"
    t.string   "status",              :default => "neutral"
    t.datetime "created_at"
    t.string   "profile_picture_url"
    t.datetime "updated_at"
  end

  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["post_id", "created_at"], :name => "index_comments_on_post_id_and_created_at"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "media", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "asset"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "post_id"
  end

  add_index "media", ["post_id"], :name => "index_media_on_post_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "comments_count", :default => 0
    t.string   "status"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contributor_id"
  end

  add_index "posts", ["contributor_id"], :name => "index_posts_on_contributor_id"
  add_index "posts", ["created_at"], :name => "index_posts_on_created_at"
  add_index "posts", ["slug"], :name => "index_posts_on_slug", :unique => true
  add_index "posts", ["updated_at"], :name => "index_posts_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "alias",                                                 :null => false
    t.string   "slug"
    t.string   "role"
    t.integer  "karma"
    t.string   "fb_userid"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_picture_url"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["alias"], :name => "index_users_on_alias", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["fb_userid"], :name => "index_users_on_fb_userid"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug"

end
