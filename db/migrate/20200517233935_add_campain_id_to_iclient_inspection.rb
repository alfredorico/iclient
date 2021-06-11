class AddCampainIdToIclientInspection < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :campain_id, :integer
  end
end
