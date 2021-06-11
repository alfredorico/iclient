class CreateIclientVehicleParts < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_vehicle_parts, id: false do |t|
      t.integer :id
      t.string :description
      t.integer :agrupation
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_vehicle_parts add primary key (id);
        SQL
      end
    end    
  end
end
