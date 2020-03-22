class InitialSetup < ActiveRecord::Migration[6.0]
  def up

    create_table "articles", force: :cascade do |t|
      t.string   "title",      limit: 255
      t.string   "slug",       limit: 255
      t.text     "content",    limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "articles", ["slug"], name: "index_articles_on_slug", unique: true, using: :btree

    create_table "audios", force: :cascade do |t|
      t.integer "post_id", limit: 4
      t.string  "url",     limit: 255
      t.integer "bytes",   limit: 4
    end

    add_index "audios", ["post_id"], name: "index_audios_on_post_id", using: :btree

    create_table "comments", force: :cascade do |t|
      t.integer  "post_id",             limit: 4
      t.integer  "user_id",             limit: 4
      t.string   "author",              limit: 255
      t.string   "author_email",        limit: 255
      t.string   "author_ip",           limit: 255
      t.text     "content",             limit: 65535
      t.string   "status",              limit: 255,   default: "neutral"
      t.datetime "created_at"
      t.string   "profile_picture_url", limit: 255
      t.datetime "updated_at"
    end

    add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
    add_index "comments", ["post_id", "created_at"], name: "index_comments_on_post_id_and_created_at", using: :btree
    add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

    create_table "friendly_id_slugs", force: :cascade do |t|
      t.string   "slug",           limit: 255, null: false
      t.integer  "sluggable_id",   limit: 4,   null: false
      t.string   "sluggable_type", limit: 40
      t.datetime "created_at"
    end

    add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
    add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

    create_table "media", force: :cascade do |t|
      t.string   "name",        limit: 255
      t.string   "description", limit: 255
      t.string   "asset",       limit: 255
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
      t.integer  "post_id",     limit: 4
    end

    add_index "media", ["post_id"], name: "index_media_on_post_id", using: :btree

    create_table "posts", force: :cascade do |t|
      t.string   "title",          limit: 255
      t.text     "content",        limit: 65535
      t.integer  "comments_count", limit: 4,     default: 0
      t.string   "status",         limit: 255
      t.string   "slug",           limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "contributor_id", limit: 4
    end

    add_index "posts", ["contributor_id"], name: "index_posts_on_contributor_id", using: :btree
    add_index "posts", ["created_at"], name: "index_posts_on_created_at", using: :btree
    add_index "posts", ["slug"], name: "index_posts_on_slug", unique: true, using: :btree
    add_index "posts", ["updated_at"], name: "index_posts_on_updated_at", using: :btree

    create_table "users", force: :cascade do |t|
      t.string   "email",                  limit: 255, default: "", null: false
      t.string   "encrypted_password",     limit: 128, default: "", null: false
      t.string   "alias",                  limit: 255,              null: false
      t.string   "slug",                   limit: 255
      t.string   "role",                   limit: 255
      t.integer  "karma",                  limit: 4
      t.string   "fb_userid",              limit: 255
      t.string   "reset_password_token",   limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          limit: 4,   default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip",     limit: 255
      t.string   "last_sign_in_ip",        limit: 255
      t.string   "confirmation_token",     limit: 255
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "profile_picture_url",    limit: 255
      t.string   "unconfirmed_email",      limit: 255
    end

    add_index "users", ["alias"], name: "index_users_on_alias", unique: true, using: :btree
    add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["fb_userid"], name: "index_users_on_fb_userid", using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    add_index "users", ["slug"], name: "index_users_on_slug", using: :btree

  end
end
