class AddExcludeDeductibleToIclientVehicleParts < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_vehicle_parts, :exclude_deductible, :boolean
  end
end
