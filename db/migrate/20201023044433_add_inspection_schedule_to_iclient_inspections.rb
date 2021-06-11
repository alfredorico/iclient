class AddInspectionScheduleToIclientInspections < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :inspection_schedule, :string
  end
end
