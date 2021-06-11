class ChangeScheduleType < ActiveRecord::Migration[6.0]
  def change
    change_column :iclient_inspections, :inspection_schedule, 'timestamp USING CAST(inspection_schedule AS timestamp)'
  end
end
