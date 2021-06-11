class CreateIclientVehicleModels < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_vehicle_models, id: false do |t|
      t.string :id
      t.string :description
      t.string :vehicle_brand_id
      t.string :brand_description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_vehicle_models add primary key (id);
        SQL
      end
    end      
  end
end
