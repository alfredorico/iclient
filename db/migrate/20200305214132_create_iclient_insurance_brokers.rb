class CreateIclientInsuranceBrokers < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_insurance_brokers, id: false do |t|
      t.integer :id
      t.string :rut
      t.string :name
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          alter table iclient_insurance_brokers add primary key (id);
        SQL
      end
    end      
  end
end
