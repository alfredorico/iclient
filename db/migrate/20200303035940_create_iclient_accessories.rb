class CreateIclientAccessories < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_accessories, id: false do |t|
      t.integer :id
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_accessories add primary key (id);
        SQL
      end
    end     
  end
end
