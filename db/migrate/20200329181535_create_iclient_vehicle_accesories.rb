class CreateIclientVehicleAccesories < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_vehicle_accessories do |t|
      t.integer :inspection_id
      t.integer :accessory_id
      t.integer :accessory_feature_id
      t.text    :value
      t.timestamps
    end
  end
end
