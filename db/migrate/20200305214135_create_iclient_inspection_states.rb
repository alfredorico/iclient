class CreateIclientInspectionStates < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_inspection_states, id: false do |t|
      t.integer :id
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_inspection_states add primary key (id);
        SQL
      end
    end  

  end
end
