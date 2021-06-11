class CreateIclientAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_attachments do |t|
      t.integer :inspection_id
      t.string :type, default: :photo
      t.integer :id_attachment
      t.text :data
      t.string :name
      t.timestamps
    end
  end
end
