class CreateIclientVehicleTargets < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_vehicle_targets, id: false do |t|
      t.integer :id
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_vehicle_targets add primary key (id);
        SQL
      end
    end  
  end
end
