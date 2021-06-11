class CreateIclientInspectionTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_inspection_types, id: false do |t|
      t.integer :id
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute "alter table iclient_inspection_types add primary key (id);"
      end
    end

  end
end
