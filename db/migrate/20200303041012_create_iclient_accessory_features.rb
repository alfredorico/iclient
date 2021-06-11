class CreateIclientAccessoryFeatures < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_accessory_features, id: false do |t|
      t.integer :id
      t.string :description
      t.integer :accesory_id

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_accessory_features add primary key (id);
        SQL
      end
    end    
  end
end
