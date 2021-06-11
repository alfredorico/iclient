class CreateIclientDamages < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_damages do |t|
      t.integer :inspection_id
      t.integer :vehicle_part_id #Idpartepieza
      t.integer :damage_type_id #IdDano
      t.integer :perspective_id #IdPerspectiva
      t.numeric :deductible, default: 0 #Deducible

      t.timestamps
    end
    add_index :iclient_damages, :inspection_id
  end
end