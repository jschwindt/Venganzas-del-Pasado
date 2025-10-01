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

ActiveRecord::Schema[8.1].define(version: 2020_08_29_003729) do
  create_table "articles", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "audios", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "bytes"
    t.integer "post_id"
    t.integer "speech_to_text_status", default: 0
    t.string "url"
    t.index ["post_id"], name: "index_audios_on_post_id"
  end

  create_table "comments", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "author"
    t.string "author_email"
    t.string "author_ip"
    t.text "content", size: :medium, collation: "utf8mb4_general_ci"
    t.datetime "created_at", precision: nil
    t.integer "post_id"
    t.string "profile_picture_url"
    t.string "status", default: "neutral"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["post_id", "created_at"], name: "index_comments_on_post_id_and_created_at"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "friendly_id_slugs", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 40
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "media", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "asset"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "name"
    t.integer "post_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["post_id"], name: "index_media_on_post_id"
  end

  create_table "posts", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "comments_count", default: 0
    t.text "content"
    t.integer "contributor_id"
    t.datetime "created_at", precision: nil
    t.string "slug"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["contributor_id"], name: "index_posts_on_contributor_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["updated_at"], name: "index_posts_on_updated_at"
  end

  create_table "texts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "audio_id", null: false
    t.text "text"
    t.integer "time"
    t.index ["audio_id", "time"], name: "audio_id_time"
  end

  create_table "users", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "alias", null: false
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "fb_userid"
    t.integer "karma"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "profile_picture_url"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "role"
    t.integer "sign_in_count", default: 0
    t.string "slug"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil
    t.index ["alias"], name: "index_users_on_alias", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["fb_userid"], name: "index_users_on_fb_userid"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end
end
