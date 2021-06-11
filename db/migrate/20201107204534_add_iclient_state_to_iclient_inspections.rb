class AddIclientStateToIclientInspections < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :iclient_state, :string
    add_column :iclient_inspections, :iclient_state_updated_in_company, :boolean
  end
end
