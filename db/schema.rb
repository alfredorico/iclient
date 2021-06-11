# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_12_011444) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "iclient_accessories", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_accessory_features", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.integer "accesory_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_attachments", force: :cascade do |t|
    t.integer "inspection_id"
    t.string "type", default: "photo"
    t.integer "id_attachment"
    t.text "data"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_check_lists", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_cities", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_communes", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.integer "city_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_damage_severities", id: :string, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_damage_types", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_damages", force: :cascade do |t|
    t.integer "inspection_id"
    t.integer "vehicle_part_id"
    t.integer "damage_type_id"
    t.integer "perspective_id"
    t.decimal "deductible", default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "damage_severity_id"
    t.index ["inspection_id"], name: "index_iclient_damages_on_inspection_id"
  end

  create_table "iclient_inspection_origins", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_inspection_states", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_inspection_types", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_inspections", force: :cascade do |t|
    t.integer "inspection_state_id"
    t.integer "insurance_broker_id"
    t.integer "inspection_type_id"
    t.integer "inspection_origin_id"
    t.text "address"
    t.integer "commune_id"
    t.string "commune_description"
    t.string "client_rut"
    t.string "client_rut_vd"
    t.string "insured_first_name"
    t.string "insured_last_name"
    t.string "insured_mother_last_name"
    t.string "contact"
    t.string "phone_number"
    t.string "email", default: "contacto@company.com"
    t.string "vehicle_brand_id"
    t.string "vehicle_brand_description"
    t.string "vehicle_model_id"
    t.string "vehicle_model_description"
    t.string "patent"
    t.string "chassis_number"
    t.boolean "chassis_number_fixed", default: false
    t.string "motor_number"
    t.integer "vehicle_target_id"
    t.integer "vehicle_type_id"
    t.integer "vehicle_year"
    t.string "vehicle_color"
    t.integer "id_inspection"
    t.integer "km"
    t.integer "number_of_doors"
    t.integer "vehicle_transmission_type_id"
    t.datetime "inspection_date"
    t.text "general_observation"
    t.boolean "error_matching_brand_model", default: false
    t.string "mission_id"
    t.datetime "sent_iclient_at"
    t.integer "http_status", default: 200
    t.string "http_response_body"
    t.string "state"
    t.string "sub_state"
    t.boolean "inspection_successfully", default: false
    t.string "inspection_failed_reason"
    t.text "additional_instruction"
    t.boolean "successfully_notify"
    t.text "response_message"
    t.text "response_message_extra"
    t.string "workflow_step", default: "received"
    t.boolean "unexpected_exception", default: false
    t.text "unexpected_exception_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "campain_id"
    t.boolean "is_clone", default: false
    t.integer "insurance_inspector_id", default: 237
    t.boolean "rejected_by_iclient_validation_service", default: false
    t.datetime "inspection_schedule"
    t.string "original_mission_id"
    t.string "iclient_state"
    t.boolean "iclient_state_updated_in_company"
    t.boolean "need_reduce_size_photos"
    t.integer "request_id"
    t.index ["mission_id"], name: "index_iclient_inspections_on_mission_id"
    t.index ["workflow_step"], name: "index_iclient_inspections_on_workflow_step"
  end

  create_table "iclient_insurance_brokers", id: :integer, default: nil, force: :cascade do |t|
    t.string "rut"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_perspectives", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_vehicle_accessories", force: :cascade do |t|
    t.integer "inspection_id"
    t.integer "accessory_id"
    t.integer "accessory_feature_id"
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_vehicle_brands", id: :string, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "gama"
  end

  create_table "iclient_vehicle_check_lists", force: :cascade do |t|
    t.integer "inspection_id"
    t.integer "check_list_id"
    t.boolean "value", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_vehicle_models", id: :string, force: :cascade do |t|
    t.string "description"
    t.string "vehicle_brand_id"
    t.string "brand_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_vehicle_parts", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.integer "agrupation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "exclude_deductible"
  end

  create_table "iclient_vehicle_targets", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_vehicle_transmission_types", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iclient_vehicle_types", id: :integer, default: nil, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "weight"
  end

end
