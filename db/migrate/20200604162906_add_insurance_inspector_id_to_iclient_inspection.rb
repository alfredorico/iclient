class AddInsuranceInspectorIdToIclientInspection < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :insurance_inspector_id, :integer, default: 237
  end
end
