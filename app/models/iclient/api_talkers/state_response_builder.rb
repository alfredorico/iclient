module Iclient
  module ApiTalkers
    class StateResponseBuilder < Inspection
  
      def responses_translater
        @responses_translater ||= ResponsesTranslater.new(mission_id: self.mission_id) 
      end

      def data
        case self.workflow_step.to_sym
        when :requested
          # De "Solicitada" (:requested) se transmitirá a "En cordinacion 18" (:precoordinate)
          <<-JSON
            {
              #{security_data}
              "IdInspeccion": #{self.id_inspection},
              "IdEstado": 18,
              "Observacion": "sin observacion",
              "IdMotivoRechazo":0,
              "Fotos":[],
              "Fecha": "#{DateTime.now.in_time_zone.strftime("%Y/%m/%d %H:%M")}"              
            }        
          JSON
        when :precoordinated
          # De "En coordinacion 18" (:precoordinates) se pasa "Coordinada 15" (:coordinated)
          <<-JSON
            {
              #{security_data}
              "IdInspeccion": #{self.id_inspection},
              "IdEstado": 15,
              "Observacion": "Inspección agendada para la fecha y hora: #{self.inspection_schedule}"
            }        
          JSON
        when :checklist_transmitted
          # De "Checklist transmitido a el estado final de resolución
          if self.campain_id == 1450 # compara
            # 'Realizada' no matter what substate has been selected  
            <<-JSON
              {
                #{security_data}
                "IdInspeccion": #{self.id_inspection},
                "IdEstado":  3,
                "Observacion": "sin observacion"
              }        
            JSON
          elsif [1991,1992,1449].include?(self.campain_id) #iclient and 123
            if disapproved_by_checklists? # Reprobado # method defined in concern Iclient::Resolution
              <<-JSON
                {
                  #{security_data}
                  "IdInspeccion": #{self.id_inspection},
                  "IdEstado":  14,
                  "Observacion": "sin observacion"
                }        
              JSON
            else # Aprobada
              <<-JSON
                {
                  #{security_data}
                  "IdInspeccion": #{self.id_inspection},
                  "IdEstado":  13,
                  "Observacion": "sin observacion"
                }        
              JSON
            end
          end
        when :coordinated
          if can_tofail?
            # Is current_state is coordinated and can fail? then send IdEstado 4 for failed
            if self.rejected_by_iclient_validation_service == true
              <<-JSON
                {
                  #{security_data}
                  "IdInspeccion": #{self.id_inspection},
                  "IdEstado":  4,
                  "Observacion": "Vehículo No Asegurable por Políticas de Suscripción de la Compañía.",
                  "IdMotivoRechazo": 11
                }        
              JSON
            elsif [1991,1992,1449].include?(self.campain_id) and self.inspection_successfully == true  and rejected_by_checklists?  # Just for iclient Fallida # method defined in concern Iclient::Resolution
              <<-JSON
                {
                  #{security_data}
                  "IdInspeccion": #{self.id_inspection},
                  "IdEstado":  4,
                  "Observacion": "Vehículo No Asegurable por Políticas de Suscripción de la Compañía.",
                  "IdMotivoRechazo": 11
                }        
              JSON
            elsif reject_reason == 5 # if inspection failed due to customer not appear a photo must be sent as evidence
              base64 = convert_base64(url: responses_translater.inspection_failed_photo)
              <<-JSON
                {
                  #{security_data}
                  "IdInspeccion": #{self.id_inspection},
                  "IdEstado":  4,
                  "Observacion": "#{ responses_translater.comment || self.disapprove_comment || 'sin observaciones' }",
                  "IdMotivoRechazo": #{reject_reason},
                  "Fotos": [
                    "#{base64}"
                  ],
                  "Fecha": "#{DateTime.now.in_time_zone.strftime("%Y/%m/%d %H:%M")}"
                }        
              JSON
            else
              if self.state == 'disapproved' and self.sub_state == 'forced_failure'
                <<-JSON
                  {
                    #{security_data}
                    "IdInspeccion": #{self.id_inspection},
                    "IdEstado":  4,
                    "Observacion": "Se transmita fallida por error de datos",
                    "IdMotivoRechazo": 5
                  }        
                JSON
              elsif self.state == 'disapproved' and self.sub_state == 'already_inspected'
                <<-JSON
                  {
                    #{security_data}
                    "IdInspeccion": #{self.id_inspection},
                    "IdEstado":  4,
                    "Observacion": "Cliente indica que el vehículo ya fue inspeccionado",
                    "IdMotivoRechazo": 9
                  }        
                JSON
              else
                <<-JSON
                  {
                    #{security_data}
                    "IdInspeccion": #{self.id_inspection},
                    "IdEstado":  4,
                    "Observacion": "#{ responses_translater.comment || self.disapprove_comment || 'sin observaciones' }",
                    "IdMotivoRechazo": #{reject_reason}
                  }        
                JSON
              end
            end
          end
        else
          '{}'
        end
      end

      def reject_reason
        if self.state == 'disapproved'
          case self.sub_state
          when 'wrong_address','out_of_coverage', 'dangerous_sector', 'forced_failure', 'rejected' # data_error for forcing 
            6
          when 'repeated'
            9
          when 'not_found_customer' 
            4
          when 'customer_rejects'
            1 # código problema de telefono
          when 'already_inspected'
            9
          when 'vehicle_under_repair'
            2
          else
            if responses_translater.inspection_failed_reason.present?
              {
                'la geolocalización de la dirección está errónea' => 6,
                'la dirección indicada no es la correcta' => 6,
                'en la dirección indicada, falta información' => 6,
                'el cliente no se presenta a la inspección' => 5,
                'cliente desiste de inspección/seguro' => 4,
                'vehículo sucio (tierra/polvo/barro)' => 5
              }[responses_translater.inspection_failed_reason]          
            end
          end           
        elsif self.state == 'approved' 
          if responses_translater.inspection_failed_reason.present?
            {
              'la geolocalización de la dirección está errónea' => 5,
              'la dirección indicada no es la correcta' => 5,
              'en la dirección indicada, falta información' => 5,
              'el cliente no se presenta a la inspección' => 5,
              'cliente desiste de inspección/seguro' => 4,
              'vehículo sucio (tierra/polvo/barro)' => 5
            }[responses_translater.inspection_failed_reason]
          else
            case self.sub_state
            when 'customer_not_appear' 
              3
            when 'customer_rejects'
              4
            end   
          end
        end  
      end

      def security_data
        <<-JSON_PART
          "Permiso": {
            "IdIngresoUsuario": "#{id_ingreso_usuario}",
            "RutUsuario": #{rut_usuario},
            "IdUsuario": #{id_usuario},
            "Ip": "",
            "Origen": 1            
          },        
        JSON_PART
      end

      def convert_base64(url:)
        require 'open-uri'
        begin
          if url
            img = open(url)
            Base64.encode64(img.read)
          end
        rescue => e
          puts "Base64 Excepción url #{url} en missión #{self.mission_id}: #{e.message}"
        end
      end      

    end
  end
end