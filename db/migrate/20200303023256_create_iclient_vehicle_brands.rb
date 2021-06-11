class CreateIclientVehicleBrands < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_vehicle_brands, id: false do |t|
      t.string :id
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute "alter table iclient_vehicle_brands add primary key (id);"
      end
    end    
  end
end
