class CreateIclientVehicleCheckLists < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_vehicle_check_lists do |t|
      t.integer :inspection_id
      t.integer :check_list_id
      t.boolean :value, default: false

      t.timestamps
    end
  end
end
