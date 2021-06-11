class CreateIclientCommunes < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_communes, id: false do |t|
      t.integer :id
      t.string :description
      t.integer :city_id

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_communes add primary key (id);
        SQL
      end
    end     
  end
end
