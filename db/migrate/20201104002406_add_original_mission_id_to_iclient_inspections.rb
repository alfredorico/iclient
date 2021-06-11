class AddOriginalMissionIdToIclientInspections < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :original_mission_id, :string
  end
end
