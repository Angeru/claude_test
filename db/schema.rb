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

ActiveRecord::Schema[7.1].define(version: 2026_02_09_153901) do
  create_table "battle_roster_units", force: :cascade do |t|
    t.integer "battle_roster_id", null: false
    t.integer "warband_member_id", null: false
    t.integer "current_wounds", default: 1, null: false
    t.integer "max_wounds", default: 1, null: false
    t.boolean "defeated", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battle_roster_id", "warband_member_id"], name: "idx_battle_roster_units_on_roster_and_member", unique: true
    t.index ["battle_roster_id"], name: "index_battle_roster_units_on_battle_roster_id"
    t.index ["warband_member_id"], name: "index_battle_roster_units_on_warband_member_id"
  end

  create_table "battle_rosters", force: :cascade do |t|
    t.integer "matchup_id", null: false
    t.integer "warband_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matchup_id", "warband_id"], name: "index_battle_rosters_on_matchup_id_and_warband_id", unique: true
    t.index ["matchup_id"], name: "index_battle_rosters_on_matchup_id"
    t.index ["warband_id"], name: "index_battle_rosters_on_warband_id"
  end

  create_table "campaign_rounds", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "round_number", null: false
    t.date "played_at"
    t.string "scenario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "round_number"], name: "index_campaign_rounds_on_campaign_id_and_round_number", unique: true
    t.index ["campaign_id"], name: "index_campaign_rounds_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.integer "user_id", null: false
    t.string "status", default: "activa", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_date"], name: "index_campaigns_on_end_date"
    t.index ["start_date"], name: "index_campaigns_on_start_date"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "matchups", force: :cascade do |t|
    t.integer "campaign_round_id", null: false
    t.integer "warband_1_id", null: false
    t.integer "warband_2_id", null: false
    t.integer "warband_1_score", default: 0
    t.integer "warband_2_score", default: 0
    t.integer "warband_1_casualties", default: 0
    t.integer "warband_2_casualties", default: 0
    t.boolean "warband_1_primary_objective", default: false
    t.boolean "warband_2_primary_objective", default: false
    t.boolean "warband_1_secondary_objective", default: false
    t.boolean "warband_2_secondary_objective", default: false
    t.integer "winner_id"
    t.string "result"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_round_id"], name: "index_matchups_on_campaign_round_id"
    t.index ["result"], name: "index_matchups_on_result"
    t.index ["warband_1_id"], name: "index_matchups_on_warband_1_id"
    t.index ["warband_2_id"], name: "index_matchups_on_warband_2_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "campaign_id", null: false
    t.datetime "subscribed_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "warband_id"
    t.index ["campaign_id"], name: "index_subscriptions_on_campaign_id"
    t.index ["user_id", "campaign_id"], name: "index_subscriptions_on_user_id_and_campaign_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
    t.index ["warband_id"], name: "index_subscriptions_on_warband_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "warband_equipments", force: :cascade do |t|
    t.integer "warband_member_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "equipment_type", null: false
    t.integer "cost", default: 0, null: false
    t.integer "movimiento_modifier", default: 0, null: false
    t.integer "lucha_modifier", default: 0, null: false
    t.integer "proyectiles_modifier", default: 0, null: false
    t.integer "fuerza_modifier", default: 0, null: false
    t.integer "defensa_modifier", default: 0, null: false
    t.integer "ataques_modifier", default: 0, null: false
    t.integer "heridas_modifier", default: 0, null: false
    t.integer "coraje_modifier", default: 0, null: false
    t.integer "inteligencia_modifier", default: 0, null: false
    t.integer "might_modifier", default: 0, null: false
    t.integer "will_modifier", default: 0, null: false
    t.integer "fate_modifier", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_type"], name: "index_warband_equipments_on_equipment_type"
    t.index ["warband_member_id"], name: "index_warband_equipments_on_warband_member_id"
  end

  create_table "warband_members", force: :cascade do |t|
    t.integer "warband_id", null: false
    t.string "name", null: false
    t.string "member_type", default: "warrior", null: false
    t.integer "movimiento", default: 6, null: false
    t.integer "lucha", default: 3, null: false
    t.integer "proyectiles", default: 3, null: false
    t.integer "fuerza", default: 3, null: false
    t.integer "defensa", default: 3, null: false
    t.integer "ataques", default: 1, null: false
    t.integer "heridas", default: 1, null: false
    t.integer "coraje", default: 3, null: false
    t.integer "inteligencia", default: 1, null: false
    t.integer "might", default: 0, null: false
    t.integer "will", default: 0, null: false
    t.integer "fate", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "experience", default: 0, null: false
    t.index ["member_type"], name: "index_warband_members_on_member_type"
    t.index ["warband_id"], name: "index_warband_members_on_warband_id"
  end

  create_table "warband_skills", force: :cascade do |t|
    t.integer "warband_member_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "skill_type", null: false
    t.integer "cost", default: 0, null: false
    t.integer "movimiento_modifier", default: 0, null: false
    t.integer "lucha_modifier", default: 0, null: false
    t.integer "proyectiles_modifier", default: 0, null: false
    t.integer "fuerza_modifier", default: 0, null: false
    t.integer "defensa_modifier", default: 0, null: false
    t.integer "ataques_modifier", default: 0, null: false
    t.integer "heridas_modifier", default: 0, null: false
    t.integer "coraje_modifier", default: 0, null: false
    t.integer "inteligencia_modifier", default: 0, null: false
    t.integer "might_modifier", default: 0, null: false
    t.integer "will_modifier", default: 0, null: false
    t.integer "fate_modifier", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_type"], name: "index_warband_skills_on_skill_type"
    t.index ["warband_member_id"], name: "index_warband_skills_on_warband_member_id"
  end

  create_table "warbands", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.integer "campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gold", default: 0, null: false
    t.integer "influence", default: 0, null: false
    t.index ["campaign_id"], name: "index_warbands_on_campaign_id"
    t.index ["user_id", "campaign_id"], name: "index_warbands_on_user_and_campaign", unique: true, where: "campaign_id IS NOT NULL"
    t.index ["user_id"], name: "index_warbands_on_user_id"
  end

  add_foreign_key "battle_roster_units", "battle_rosters"
  add_foreign_key "battle_roster_units", "warband_members"
  add_foreign_key "battle_rosters", "matchups"
  add_foreign_key "battle_rosters", "warbands"
  add_foreign_key "campaign_rounds", "campaigns"
  add_foreign_key "campaigns", "users"
  add_foreign_key "matchups", "campaign_rounds"
  add_foreign_key "matchups", "warbands", column: "warband_1_id"
  add_foreign_key "matchups", "warbands", column: "warband_2_id"
  add_foreign_key "matchups", "warbands", column: "winner_id"
  add_foreign_key "subscriptions", "campaigns"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "subscriptions", "warbands"
  add_foreign_key "warband_equipments", "warband_members"
  add_foreign_key "warband_members", "warbands"
  add_foreign_key "warband_skills", "warband_members"
  add_foreign_key "warbands", "campaigns"
  add_foreign_key "warbands", "users"
end
