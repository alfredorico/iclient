class AddNeedReduceSizePhotosToIclientInspections < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :need_reduce_size_photos, :boolean
  end
end
