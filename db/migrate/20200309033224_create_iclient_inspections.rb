class CreateIclientInspections < ActiveRecord::Migration[6.0]
  def change
    create_table :iclient_inspections do |t|
      t.integer :inspection_state_id
      t.integer :insurance_broker_id #IdCorredor
      t.integer :inspection_type_id #IdInspeccionTipo
      t.integer :inspection_origin_id #IdOrigenInspeccion
      t.text    :address #DireccionDomicilio
      t.integer :commune_id #IdComunaDomicilio
      t.string  :commune_description
      t.string  :client_rut #RutCliente
      t.string  :client_rut_vd #RutDvCliente  #digito verificacion rut cliente
      t.string  :insured_first_name #NombreAsegurado
      t.string  :insured_last_name #ApellidoPaterno
      t.string  :insured_mother_last_name #ApellidoMaterno
      t.string  :contact #Contacto
      t.string  :phone_number #NumeroTelefono
      t.string  :email, default: 'contacto@company.com'
      t.string  :vehicle_brand_id  #CodMarca
      t.string  :vehicle_brand_description #DescripcionMarca
      t.string  :vehicle_model_id  # CodModelo
      t.string  :vehicle_model_description #DescripcionModelo
      t.string  :patent #Patente
      t.string  :chassis_number
      t.boolean :chassis_number_fixed, default: false
      t.string  :motor_number
      t.integer :vehicle_target_id  #IdUso
      t.integer :vehicle_type_id #IdTipoVehiculo
      t.integer :vehicle_year #Año
      t.string  :vehicle_color # Color
      t.integer :id_inspection # Created from service
      t.integer :km
      t.integer :number_of_doors
      t.integer :vehicle_transmission_type_id
      t.datetime :inspection_date #FechaInspeccion
      t.text :general_observation
      t.boolean :error_matching_brand_model, default: false
      t.string :mission_id, index: true
      t.datetime :sent_iclient_at
      t.integer :http_status, default: 200
      t.string :http_response_body
      t.string :state
      t.string :sub_state
      t.boolean :inspection_successfully, default: false
      t.string :inspection_failed_reason
      t.text :additional_instruction
      t.boolean :successfully_notify
      t.text :response_message
      t.text :response_message_extra
      t.string :workflow_step, default: 'received'
      t.boolean :unexpected_exception,  default: false
      t.text :unexpected_exception_message
      t.timestamps
    end
    
    add_index :iclient_inspections, :workflow_step

  end
end
