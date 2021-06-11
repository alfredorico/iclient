class AddRejectedByIclientValidationServiceToIclientInspections < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_inspections, :rejected_by_iclient_validation_service, :boolean, default: false
  end
end
