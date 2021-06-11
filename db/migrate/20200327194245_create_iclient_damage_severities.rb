class CreateIclientDamageSeverities < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_damage_severities, id: false do |t|
      t.string :id
      t.string :description
      t.timestamps
    end

    add_column :iclient_damages, :damage_severity_id, :string

    reversible do |dir|
      dir.up do
        execute "alter table iclient_damage_severities add primary key (id);"
      end
    end 
  end
end
