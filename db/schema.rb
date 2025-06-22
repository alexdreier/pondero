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

ActiveRecord::Schema[8.0].define(version: 2025_06_22_021724) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "journal_submission_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journal_submission_id", "created_at"], name: "index_comments_on_journal_submission_id_and_created_at"
    t.index ["journal_submission_id"], name: "index_comments_on_journal_submission_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "journal_id", null: false
    t.date "entry_date"
    t.string "status", default: "draft"
    t.string "title"
    t.text "description"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_date"], name: "index_journal_entries_on_entry_date"
    t.index ["journal_id"], name: "index_journal_entries_on_journal_id"
    t.index ["status"], name: "index_journal_entries_on_status"
    t.index ["user_id", "journal_id"], name: "index_journal_entries_on_user_id_and_journal_id"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "journal_submissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "journal_id", null: false
    t.datetime "completed_at"
    t.string "status", default: "in_progress"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journal_id", "user_id"], name: "index_journal_submissions_on_journal_id_and_user_id"
    t.index ["journal_id"], name: "index_journal_submissions_on_journal_id"
    t.index ["user_id"], name: "index_journal_submissions_on_user_id"
  end

  create_table "journals", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id", null: false
    t.bigint "theme_id"
    t.datetime "available_from"
    t.datetime "available_until"
    t.boolean "published", default: false
    t.integer "position"
    t.string "status", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "private", null: false
    t.string "access_level", default: "restricted", null: false
    t.string "canvas_course_id", comment: "Canvas LMS Course ID"
    t.text "canvas_course_url", comment: "Full Canvas Course URL"
    t.string "canvas_course_name", comment: "Canvas Course Display Name"
    t.string "canvas_assignment_id", comment: "Canvas Assignment ID if created as assignment"
    t.boolean "lti_enabled", default: false, comment: "Whether this journal supports LTI integration"
    t.index ["access_level"], name: "index_journals_on_access_level"
    t.index ["canvas_course_id"], name: "index_journals_on_canvas_course_id"
    t.index ["lti_enabled"], name: "index_journals_on_lti_enabled"
    t.index ["published"], name: "index_journals_on_published"
    t.index ["theme_id"], name: "index_journals_on_theme_id"
    t.index ["user_id", "published"], name: "index_journals_on_user_id_and_published"
    t.index ["user_id"], name: "index_journals_on_user_id"
    t.index ["visibility", "published"], name: "index_journals_on_visibility_and_published"
    t.index ["visibility"], name: "index_journals_on_visibility"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "journal_id", null: false
    t.text "content"
    t.string "question_type"
    t.text "options"
    t.boolean "required"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "section_id"
    t.index ["journal_id", "position"], name: "index_questions_on_journal_id_and_position"
    t.index ["journal_id"], name: "index_questions_on_journal_id"
    t.index ["question_type"], name: "index_questions_on_question_type"
    t.index ["section_id"], name: "index_questions_on_section_id"
  end

  create_table "response_feedbacks", force: :cascade do |t|
    t.bigint "response_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.boolean "read_by_student", default: false, null: false
    t.integer "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_response_feedbacks_on_parent_id"
    t.index ["response_id", "position"], name: "index_response_feedbacks_on_response_id_and_position"
    t.index ["response_id", "read_by_student"], name: "index_response_feedbacks_on_response_id_and_read_by_student"
    t.index ["response_id"], name: "index_response_feedbacks_on_response_id"
    t.index ["user_id"], name: "index_response_feedbacks_on_user_id"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.text "content"
    t.datetime "submitted_at"
    t.string "status", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "journal_entry_id"
    t.integer "feedback_count", default: 0, null: false
    t.integer "unread_feedback_count", default: 0, null: false
    t.datetime "last_feedback_at"
    t.index ["journal_entry_id", "question_id"], name: "index_responses_on_journal_entry_id_and_question_id", unique: true
    t.index ["journal_entry_id"], name: "index_responses_on_journal_entry_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["user_id", "question_id"], name: "index_responses_on_user_id_and_question_id"
    t.index ["user_id"], name: "index_responses_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.bigint "journal_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journal_id", "position"], name: "index_sections_on_journal_id_and_position"
    t.index ["journal_id"], name: "index_sections_on_journal_id"
    t.index ["position"], name: "index_sections_on_position"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.text "colors"
    t.text "fonts"
    t.text "layout_options"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lti_user_id"
    t.boolean "notify_on_feedback", default: true, null: false
    t.boolean "notify_on_feedback_reply", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["lti_user_id"], name: "index_users_on_lti_user_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "journal_submissions"
  add_foreign_key "comments", "users"
  add_foreign_key "journal_entries", "journals"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "journal_submissions", "journals"
  add_foreign_key "journal_submissions", "users"
  add_foreign_key "journals", "themes"
  add_foreign_key "journals", "users"
  add_foreign_key "questions", "journals"
  add_foreign_key "questions", "sections"
  add_foreign_key "response_feedbacks", "responses"
  add_foreign_key "response_feedbacks", "users"
  add_foreign_key "responses", "journal_entries"
  add_foreign_key "responses", "questions"
  add_foreign_key "responses", "users"
  add_foreign_key "sections", "journals"
end
