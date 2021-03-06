module Iclient
  module DataUpdater

    def responses_translater
      @responses_translater ||= ::Iclient::ApiTalkers::ResponsesTranslater.new(mission_id: self.mission_id) 
    end

    def update_data
      ActiveRecord::Base.transaction do

        self.state = inspection_state # set company state
        self.inspection_date = completed_date_time if completed_date_time
        self.inspection_schedule = schedule if schedule
        case inspection_state
        when :approved
          self.sub_state = approve_detail 
          self.general_observation = responses_translater.general_observation
        when :disapproved 
          self.sub_state = disapprove_detail 
        end

        self.inspection_successfully = responses_translater.inspection_successfully?
        if responses_translater.inspection_failed?
          self.inspection_failed_reason = responses_translater.inspection_failed_reason
        end

        if responses_translater.correct_patent.present?
          self.patent = responses_translater.correct_patent 
        else
          self.patent = company_patent
        end
        
        # Special case 
        if self.patent&.upcase == 'ET0000' # Constant patent for very new new new vehicle.
          self.patent = 'ET0001'
        end

        self.patent = self.patent&.gsub(Regexp.new("[^a-zA-Z0-9]"),"")

        update_vehicle_and_damages
        udpate_vehicle_accesories
        update_vehicle_check_lists

        if (self.campain_id == 1449) 
          if admin_user_id == 281067 # autoinspeccion@company.com
            self.inspection_origin_id = 7
          else
            self.inspection_origin_id = 2 # in case o release mission from taken to initial
          end
        end
        # Save all
        self.save
      end    
    rescue => e
      self.update(unexpected_exception: true, unexpected_exception_message: "#{e.message} / #{e.backtrace[0..10].to_s}")
      raise e.message 
    end

    def update_vehicle_and_damages
      if responses_translater.inspection_successfully?
        self.vehicle_type_id = responses_translater.vehicle_type_id
        self.vehicle_transmission_type_id = responses_translater.transmission_id
        self.vehicle_target_id = responses_translater.vehicle_target_id
        if self.campain_id != 1449 # For any campain but iclient/iclient
          self.vehicle_year = responses_translater.year 
        end
        self.vehicle_color = responses_translater.color
        self.km = responses_translater.km
        unless self.chassis_number_fixed
          self.chassis_number = responses_translater.chassis_number&.gsub(Regexp.new("[^a-zA-Z0-9]"),"")
        end
        self.motor_number = responses_translater.motor_number&.gsub(Regexp.new("[^a-zA-Z0-9]"),"")
        self.save
        
        self.damages.destroy_all
        self.damages.create(responses_translater.damages)
      end      
    end

    def udpate_vehicle_accesories
      if responses_translater.inspection_successfully?
        self.vehicle_accessories.destroy_all
        _vehicle_accesories = []
        # Capota
        if responses_translater.capota_type
          _vehicle_accesories << {
            accessory_id: 25, # Capota
            accessory_feature_id: ({ "cuero" => 253, "fibra" => 251, "lona" => 252  }[responses_translater.capota_type])
          }
        end

        if responses_translater.front_tire_state
          _vehicle_accesories << {
            accessory_id: 46, # Estado ruedas delanteras
            accessory_feature_id: ({ "lisos" => 463, "medio uso" => 462, "nuevos" => 461  }[responses_translater.front_tire_state])
          }
        end        

        if responses_translater.rear_tire_state
          _vehicle_accesories << {
            accessory_id: 53, # Estado ruedas traseras
            accessory_feature_id: ({ "lisos" => 533, "medio uso" => 532, "nuevos" => 531  }[responses_translater.rear_tire_state])
          }
        end        

        if responses_translater.spare_tire.present? and responses_translater.spare_tire != 'sin rueda'
          _vehicle_accesories << {
            accessory_id: 26, # Rueda de repuesto
            accessory_feature_id: ({ "rueda de emergencia" => 261, "rueda normal" => 262 }[responses_translater.spare_tire])
          }

          if responses_translater.spare_tire_cover.present?
            _vehicle_accesories << {
              accessory_id: 50, # cubierta de la rueda de repuesto
              accessory_feature_id: ({ "con seguro" => 501, "lona" => 502, "rigida" => 503, "suelto" => 504 }[responses_translater.spare_tire_cover])
            }
          end        
        end 
        
        if responses_translater.radio_type
          _vehicle_accesories << {
            accessory_id: 11, # Panel desmontable
            accessory_feature_id: ({ "panel desmontable" => 116, "panel fijo" => 1114 }[responses_translater.radio_type])
          }
        end  

        if responses_translater.upholstery_type.present?
          _vehicle_accesories << {
            accessory_id: 45, # Tipo de tapicer??a
            accessory_feature_id: ({ "cuero" => 451, "normal" => 452 }[responses_translater.upholstery_type])
          }
        end  

        if responses_translater.airbag_present == 'si'
          _vehicle_accesories << {
            accessory_id: 6, # Airbag
            accessory_feature_id: "\"\""
          }
        end  
        
        if responses_translater.selected_vehicle_accessories.any?
          responses_translater.selected_vehicle_accessories.each do |accesory|
            case accesory
            when "alarma"
              _vehicle_accesories << {
                accessory_id: 9, # alarma
                accessory_feature_id: 91 # Calificada
              }              
            when "aler??n"
              _vehicle_accesories << {
                accessory_id: 34, # aleron
                accessory_feature_id: 341, # marca
                value: "Marca Aleron"
              }              
            when "antena"
              _vehicle_accesories << {
                accessory_id: 44, # antena
                accessory_feature_id: 443 # adherida
              }              
            when "huinche "
              _vehicle_accesories << {
                accessory_id: 29, # 
                accessory_feature_id: 291, # marca
                value: "Marca Wuinches"
              }              
            when "logotipo delantero"
              _vehicle_accesories << {
                accessory_id: 96, # 
                accessory_feature_id: 961 # Always delantero because only one is allowed
              }              
            when "porta equipaje"
              _vehicle_accesories << {
                accessory_id: 40, # 
                accessory_feature_id: 403 # 
              }              
            when "sunroof"
              _vehicle_accesories << {
                accessory_id: 7, # 
                accessory_feature_id: 71 # electrico
              }              
            when "llantas de aleaci??n"
              _vehicle_accesories << {
                accessory_id: 8, # 
                accessory_feature_id: 81, # 
                value: "llantas de aleaci??n"
              }              
            when "aire acondicionado"
              _vehicle_accesories << {
                accessory_id: 5, # 
                accessory_feature_id: 51
              }              
            end
          end
        end
        
        self.vehicle_accessories.create(_vehicle_accesories)
      end
    end

    def update_vehicle_check_lists
      if responses_translater.inspection_successfully?
        self.vehicle_check_lists.destroy_all
        
        checklist_response_builder = Iclient::ApiTalkers::ChecklistResponseBuilder.find(self.id)
        _vehicle_check_lists = []

        #  1 | Capot o Maletero no abren
        _vehicle_check_lists << {
          check_list_id: 1,
          value: checklist_response_builder.is_capot_unable_to_open?
        }
        #  2 | Carrocer??a (modificaciones que alteran el rendimiento para competici??n y/o uso del veh??culo)
        _vehicle_check_lists << {
          check_list_id: 2,
          value: false
        }
        #  3 | Motor (modificaciones que alteran el rendimiento para competici??n y/o uso del veh??culo)
        _vehicle_check_lists << {
          check_list_id: 3,
          value: false
        }        
        #  4 | Neum??ticos lisos
        _vehicle_check_lists << {
          check_list_id: 4,
          value: checklist_response_builder.is_tire_flat?
        }         
        #  5 | N?? de chasis no se puede validar
        _vehicle_check_lists << {
          check_list_id: 5,
          value: checklist_response_builder.is_chassis_number_adulterated?
        }         
        #  6 | No tiene patente (salvo veh??culos nuevos con m??ximo 5 d??as h??biles)
        _vehicle_check_lists << {
          check_list_id: 6,
          value: false
        }
        #  7 | P??rdida Total
        _vehicle_check_lists << {
          check_list_id: 7,
          value: false
        }
        #  8 | Reparaci??n anterior evidentemente mal realizada
        _vehicle_check_lists << {
          check_list_id: 8,
          value: false
        }
        #  9 | Veh??culo cuerpo diplom??tico
        _vehicle_check_lists << {
          check_list_id: 9,
          value: false
        }        
        # 10 | Veh??culo de arriendo (Rent a Car)
        _vehicle_check_lists << {
          check_list_id: 10,
          value: false
        }         
        # 11 | Veh??culo de emergencia (bomberos, carabineros, ambulancia, etc.)
        _vehicle_check_lists << {
          check_list_id: 11,
          value: false
        }          
        # 12 | Veh??culo de escuela de conductores
        _vehicle_check_lists << {
          check_list_id: 12,
          value: false
        }        
        # 13 | Veh??culo de importaci??n directa o retornado
        _vehicle_check_lists << {
          check_list_id: 13,
          value: false
        }  
        # 14 | Veh??culo de locomoci??n colectiva (taxi, uber o colectivo)
        _vehicle_check_lists << {
          check_list_id: 14,
          value: false
        }          
        # 15 | Veh??culo de suscripci??n restringida
        _vehicle_check_lists << {
          check_list_id: 15,
          value: false
        }          
        # 16 | Veh??culo de uso comercial liviano
        _vehicle_check_lists << {
          check_list_id: 16,
          value: checklist_response_builder.is_lightweight_and_comercial_vehicle?
        }          
        # 17 | Veh??culo de uso comercial pesado (cami??n o bus)
        _vehicle_check_lists << {
          check_list_id: 17,
          value: checklist_response_builder.is_heavyweight_and_comercial_vehicle?
        }        
        # 18 | Veh??culo de uso particular con kilometraje superior a 30.000 kms por a??o 
        _vehicle_check_lists << {
          check_list_id: 18,
          value: checklist_response_builder.is_vehicle_km_over_40000_per_year?
        }                                                                        
        # 19 | Veh??culo descapotable
        _vehicle_check_lists << {
          check_list_id: 19,
          value: checklist_response_builder.is_convertible_vehicle?
        }            
        # 20 | Veh??culo furg??n escolar
        _vehicle_check_lists << {
          check_list_id: 20,
          value: false
        }        
        # 21 | Veh??culo liviano con antig??edad mayor a 15 a??os
        _vehicle_check_lists << {
          check_list_id: 21,
          value: checklist_response_builder.is_lightweight_vehicle_age_over_15_years?
        }         
        # 22 | Veh??culo pesado con antig??edad mayor a 20 a??os
        _vehicle_check_lists << {
          check_list_id: 22,
          value: checklist_response_builder.is_heavyweight_vehicle_age_over_20_years?
        }         
        # 23 | Veh??culos con airbag explotados o detonados
        _vehicle_check_lists << {
          check_list_id: 23,
          value: checklist_response_builder.is_airbag_busted?
        }         
        # 24 | Veh??culos con hologramas, pinturas especiales, adhesivos no originales
        _vehicle_check_lists << {
          check_list_id: 24,
          value: checklist_response_builder.is_vehicle_with_holograms?
        }        
        # 25 | Veh??culos con patente de otro color (no blanca)
        _vehicle_check_lists << {
          check_list_id: 25,
          value: false
        }   
        # 26 | Veh??culos de 3 o menos ruedas
        _vehicle_check_lists << {
          check_list_id: 26,
          value: false
        }           
        # 27 | Veh??culos ingresados por franquicia aduanera
        _vehicle_check_lists << {
          check_list_id: 27,
          value: false
        }           
        # 28 | Veh??culos livianos: La sumatoria de da??os supera 12 UF o tiene m??s de 10 da??os
        _vehicle_check_lists << {
          check_list_id: 28,
          value: checklist_response_builder.is_lightweight_vehicle_and_over_10_damages?
        }          
        # 29 | Veh??culos pesados: La sumatoria de da??os supera 24 UF o tiene m??s de 3 da??os
        _vehicle_check_lists << {
          check_list_id: 29,
          value: checklist_response_builder.is_heavyweight_vehicle_and_over_3_damages?
        }    

        self.vehicle_check_lists.create(_vehicle_check_lists)



      end      
    end

    def update_iclient_state
      begin

        if self.patent.try(:upcase) == 'ET0001'
          data = <<-XML
          <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsc="http://tempuri.org/WSIclientInspeccion/WsIclientInspeccion">
            <soapenv:Header/>
            <soapenv:Body>
                <wsc:ConsultarEstadoInspeccionVehiculoEXTERNO>
                  <wsc:vExisteInspeccionVehiculosExterno>
                      <wsc:IDIngreso>COL20161200021213</wsc:IDIngreso>
                      <wsc:patente>#{self.patent}</wsc:patente>
                      <wsc:Motor>#{self.motor_number}</wsc:Motor>
                      <wsc:Chasis>#{self.chassis_number}</wsc:Chasis>            
                  </wsc:vExisteInspeccionVehiculosExterno>
                </wsc:ConsultarEstadoInspeccionVehiculoEXTERNO>
            </soapenv:Body>
          </soapenv:Envelope>
          XML
        else
          data = <<-XML
          <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsc="http://tempuri.org/WSIclientInspeccion/WsIclientInspeccion">
            <soapenv:Header/>
            <soapenv:Body>
                <wsc:ConsultarEstadoInspeccionVehiculoEXTERNO>
                  <wsc:vExisteInspeccionVehiculosExterno>
                      <wsc:IDIngreso>COL20161200021213</wsc:IDIngreso>
                      <wsc:patente>#{self.patent}</wsc:patente>
                  </wsc:vExisteInspeccionVehiculosExterno>
                </wsc:ConsultarEstadoInspeccionVehiculoEXTERNO>
            </soapenv:Body>
          </soapenv:Envelope>
          XML
        end

        response = ::HTTParty.send(:post, "http://www1.iclient.cl/Corporate/Web/WSIclientInspeccion/WSIclientInspeccion.asmx", { 
          headers: {
            'Content-Type' => 'text/xml;charset=UTF-8',
            "Accept" => "application/xml",
            "SOAPAction" => "http://tempuri.org/WSIclientInspeccion/WsIclientInspeccion/ConsultarEstadoInspeccionVehiculoEXTERNO"
          },
          body: data
        })
        iclient_service = Nokogiri::XML(response.body.to_s)
        if iclient_service.child.child.child.child.name == "faultcode"
          self.update(iclient_state: 'F')
          SlackNotifier::CompanyAlerts.ping("<@U6NBF7DKN> Error en consulta a Servicio SOAP de Iclient para mission #{self.mission_id} patente #{self.patent}: \n#{iclient_service.to_s}")
        else
          r = iclient_service.children.children.children.children.children.to_a.find {|d| d.name == "CodRespuesta" }
          if r.present?
            self.update(
              iclient_state: r.text              
            ) # Success condition
          else
            SlackNotifier::CompanyAlerts.ping("<@U6NBF7DKN> Respuesta erronea de SOAP de Iclient para mission #{self.mission_id} patente #{self.patent}: \n#{iclient_service.to_s}")
            self.update(iclient_state: 'F')
          end
        end
      rescue => e
        self.update(iclient_state: 'F')
        SlackNotifier::CompanyAlerts.ping("<@U6NBF7DKN> Excepci??n en consulta a Servicio SOAP de Iclient para mission #{self.mission_id} patente #{self.patent}: #{e.message}")
      end   
    end

    def update_iclient_state_in_company(consume_soap: true)
      return unless self.campain_id == 1450 # this method is only for compara
      if consume_soap
        update_iclient_state
      end
      if ['1','2','3','5'].include?(self.iclient_state)
        put_company_substate
      end      
    end

    def update_iclient_resolution_in_company
      return unless [1449, 1991, 1992].include?(self.campain_id) # this method is only for compara and 123seguros
      if self.state == 'disapproved'
        self.update(iclient_state: '4')
        return
      elsif self.inspection_successfully == true and disapproved_by_checklists?
        self.update(iclient_state: '14')
      elsif self.inspection_successfully == true and rejected_by_checklists? 
        self.update(iclient_state: '4') # in case of not detected by iclient service
        SlackNotifier::CompanyTI.ping("<@U6NBF7DKN> #{self.mission_id} patente #{self.patent} CASO POCO COMUN DE CHECKLIST ids (21,22,5) NO DETECTADOS POR SERVICIO ICLIENT AL RECEPCIONAR")
      elsif self.state == 'approved' and self.inspection_successfully == false
        self.update(iclient_state: '4') # in case of not detected by iclient service
        return
      elsif self.state == 'approved' and self.inspection_successfully == true
        self.update(iclient_state: '13')
      else
        self.update(iclient_state: 'X')
        SlackNotifier::CompanyTI.ping("<@U6NBF7DKN> #{self.mission_id} patente #{self.patent} resolvio a estado X")
        return
      end
      put_company_substate
    end

    def put_company_substate
      begin
        response = HTTParty.put("#{ENV['COMPANY_URL']|| 'http://localhost:3000'}/api/missions/#{self.mission_id}/", {
          headers: Constants.company_auth_headers,
          body: {
            mission: {
              approve_detail: iclient_state_rockeptin_matching
            }
          }.to_json
        })
        if response.code == 200
          self.update(
            iclient_state_updated_in_company: true,
            sub_state: iclient_state_rockeptin_matching
          )
        else
          self.update(iclient_state_updated_in_company: false)
          SlackNotifier::CompanyTI.ping("<@U6NBF7DKN> Error al actualizar subestado en Company para la misi??n #{self.mission_id} patente #{self.patent}")          
        end
      rescue => e
        self.update(iclient_state_updated_in_company: false)          
        SlackNotifier::CompanyTI.ping("<@U6NBF7DKN> Exception al actualizar subestado en Company para la misi??n #{self.mission_id} patente #{self.patent}: #{e.message}")
      end      
    end

  end
end

