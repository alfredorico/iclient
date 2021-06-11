module Iclient
  module ApiTalkers
    class InspectionResponseBuilder < Inspection
  
      def data(overwrite_step: nil)
        _step = overwrite_step || self.workflow_step.to_sym
        case _step.to_sym
        when :received
          <<-JSON
            {              
              "permiso": {
                "IdIngresoUsuario": "#{id_ingreso_usuario}",
                "RutUsuario": #{rut_usuario},
                "IdUsuario": #{id_usuario},
                "Ip": "",
                "Origen": 1                
              },
              "inspeccion": {
                "IdRiesgo": 30,
                "IdSucRiesgo": 12,
                "DireccionRiesgo": "",
                "IdComunaRiesgo": 0,
                "IdCorredor": #{self.insurance_broker_id},
                "IdInspeccionTipo": #{self.inspection_type_id},
                "IdUsuario": #{id_usuario},
                "IdInspector": #{id_inspector},
                "ObservacionSolicitud": "#{additional_instruction&.gsub(Regexp.new("[^a-zA-Z0-9#.,:()/&°ñÑáéíóúÁÉÍÓÚ\s-]"),"")}",
                "IdOrigenInspeccion": #{self.inspection_origin_id},
                "DireccionDomicilio": "#{self.address&.gsub(Regexp.new("[^a-zA-Z0-9#.,:()/&°ñÑáéíóúÁÉÍÓÚ\s-]"),"")}",
                "IdComunaDomicilio": #{self.commune_id},
                "FechaInspeccion": null,
                "ObservacionGeneral": null                
              },
              "vehiculo": {
                "CodMarca": "#{self.vehicle_brand_id}",
                "DescripcionMarca": "#{self.vehicle_brand_description}",
                "CodModelo": "#{self.vehicle_model_id}",
                "DescripcionModelo": "#{self.vehicle_model_description}",
                "Patente": "#{self.patent&.strip}",
                "NumeroChasis": "#{self.chassis_number&.gsub(Regexp.new("[^a-zA-Z0-9]"),"") || 'SINDATA'}",
                "NumeroMotor": "#{self.motor_number&.gsub(Regexp.new("[^a-zA-Z0-9]"),"") || 'SINDATA'}",
                "IdUso": #{self.vehicle_target_id},
                "Ano": #{self.vehicle_year.to_i},
                "Color": "#{self.vehicle_color}",
                "IdTipoVehiculo": #{self.vehicle_type_id}
              },
              "asegurado": {
                "Rut": #{self.client_rut},
                "Dv": "#{self.client_rut_vd&.strip}",
                "ApellidoPaterno": "#{self.insured_last_name}",
                "ApellidoMaterno": "#{self.insured_mother_last_name}",
                "Nombres": "#{self.insured_first_name}",
                "Contacto": "#{self.contact}",
                "TelefonoParticular": "#{self.phone_number}",
                "TelefonoComercial": "",
                "Direccion": "",
                "IdComuna": 0,
                "Correo": ""
              }
            }
          JSON
        when :attachments_transmitted
          <<-JSON
            {              
              "permiso": {
                "IdIngresoUsuario": "#{id_ingreso_usuario}",
                "RutUsuario": #{rut_usuario},
                "IdUsuario": #{id_usuario},
                "Ip": "",
                "Origen": 1
              },
              "IdInspeccion": #{self.id_inspection},
              "inspeccion": {
                "IdRiesgo": 30,
                "IdSucRiesgo": 12,
                "DireccionRiesgo": "",
                "IdComunaRiesgo": 0,
                "IdCorredor": #{self.insurance_broker_id},
                "IdInspeccionTipo": #{self.inspection_type_id},
                "IdUsuario": #{id_usuario},
                "IdInspector": #{id_inspector},
                "ObservacionSolicitud": "#{additional_instruction&.gsub(Regexp.new("[^a-zA-Z0-9#.,:()/&°ñÑáéíóúÁÉÍÓÚ\s-]"),"")}",
                "IdOrigenInspeccion": #{self.inspection_origin_id},
                "DireccionDomicilio": "#{I18n.transliterate(self.address)}",
                "IdComunaDomicilio": #{self.commune_id},
                "FechaInspeccion": "#{self.inspection_date.strftime("%Y/%m/%d")}"
                #{",\"ObservacionGeneral\": \"#{self.general_observation.to_s.gsub(/[^0-9a-z ]/i,'')}\"" if self.general_observation.present?  }
              },
              "vehiculo": {
                "CodMarca": "#{self.vehicle_brand_id}",
                "DescripcionMarca": "#{self.vehicle_brand_description}",
                "CodModelo": "#{self.vehicle_model_id}",
                "DescripcionModelo": "#{self.vehicle_model_description}",
                "Patente": "#{self.patent&.strip}",
                "NumeroChasis": "#{self.chassis_number&.gsub(Regexp.new("[^a-zA-Z0-9]"),"") || 'SINDATA'}",
                "NumeroMotor": "#{self.motor_number&.gsub(Regexp.new("[^a-zA-Z0-9]"),"") || 'SINDATA'}",
                "IdUso": #{self.vehicle_target_id},
                "Ano": #{self.vehicle_year.to_i},
                "Color": "#{self.vehicle_color}",
                "IdTipoVehiculo": #{self.vehicle_type_id},
                "Kilometraje": #{self.km},
              	"IdTransmision": #{self.vehicle_transmission_type_id}
              },
              "asegurado": {
                "Rut": #{self.client_rut},
                "Dv": "#{self.client_rut_vd&.strip}",
                "ApellidoPaterno": "#{I18n.transliterate(self.insured_last_name)}",
                "ApellidoMaterno": "#{I18n.transliterate(self.insured_mother_last_name)}",
                "Nombres": "#{self.insured_first_name}",
                "Contacto": "#{self.contact}",
                "TelefonoParticular": "#{self.phone_number}",
                "TelefonoComercial": "",
                "Direccion": "#{I18n.transliterate(self.address)}",
                "IdComuna": #{self.commune_id},
                "Correo": ""
              }
            }
          JSON
        else
          '{}'
        end
      end

      def additional_instruction
        if self.campain_id == 1450 # compara
          read_attribute(:additional_instruction).to_s.gsub(/[^0-9a-z ]/i,'')
        end
      end

    end
  end
end