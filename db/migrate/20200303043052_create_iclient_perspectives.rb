class CreateIclientPerspectives < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_perspectives, id: false do |t|
      t.integer :id
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_perspectives add primary key (id);
        SQL
      end
    end    
  end
end
