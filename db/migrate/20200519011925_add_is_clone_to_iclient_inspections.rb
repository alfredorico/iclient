class AddIsCloneToIclientInspections < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :is_clone, :boolean, default: false
  end
end
