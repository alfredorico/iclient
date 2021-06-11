class AddWeightToIclientVehicleTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_vehicle_types, :weight, :string
  end
end
