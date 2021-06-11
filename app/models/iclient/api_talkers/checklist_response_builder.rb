module Iclient
  module ApiTalkers
    class ChecklistResponseBuilder < Inspection

=begin
 1  | Capot o Maletero no abren
 4  | Neumáticos lisos
 5  | Nº de chasis no se puede validar
 16 | Vehículo de uso comercial liviano
 17 | Vehículo de uso comercial pesado (camión o bus)
 18 | Vehículo de uso particular con kilometraje superior a 30.000 kms por año
 19 | Vehículo descapotable
 21 | Vehículo liviano con antigüedad mayor a 15 años
 22 | Vehículo pesado con antigüedad mayor a 20 años
 23 | Vehículos con airbag explotados o detonados
 24 | Vehículos con hologramas, pinturas especiales, adhesivos no originales
 28 | Vehículos livianos: La sumatoria de daños supera 12 UF o tiene más de 10 daños
 29 | Vehículos pesados: La sumatoria de daños supera 24 UF o tiene más de 3 daños
=end

      def responses_translater
        @responses_translater ||= ResponsesTranslater.new(mission_id: self.mission_id) 
      end

      # def is_heavyweight_vehicle?
      #   # HEAVY_MODELS.include?(self.vehicle_model_id)
      #   self.vehicle_type.weight == 'H'
      # end

      # def is_lightweight_vehicle?
      #   self.vehicle_type.weight == 'L'
      # end

      # ----------------------------------------------
      # Checklist calculation
      # 1  | Capot o Maletero no abren 
      def is_capot_unable_to_open?
        # if damages.where(vehicle_part_id: 3, damage_type_id: 1).any?
        #   true 
        # else
        #   false
        # end
        false
      end

      # 4  | Neumáticos lisos
      def is_tire_flat?
        #  46 | Neumáticos Delanteros   |  463 | Lisos
        #  53 | Neumáticos Traseros     |  533 | Lisos
        if vehicle_accessories.where(accessory_id: 53, accessory_feature_id: 533).any? or vehicle_accessories.where(accessory_id: 46, accessory_feature_id: 463).any?
          true 
        else
          false
        end          
      end

      # 5  | Nº de chasis no se puede validar
      def is_chassis_number_adulterated?
        if responses_translater.chassis_number_adulterated == 'si'
          true 
        else
          false
        end      
      end

      # 16 | Vehículo de uso comercial liviano
      def is_lightweight_and_comercial_vehicle?
        if (is_lightweight_vehicle? and (responses_translater.vehicle_target_id == 2))
          true
        else
          false
        end        
      end

      # 17 | Vehículo de uso comercial pesado (camión o bus)
      def is_heavyweight_and_comercial_vehicle?
        if is_heavyweight_vehicle? # Just for being heavyweight vehicle hence is comercial
          true
        else
          false
        end        
      end      

      # 18 | Vehículo de uso particular con kilometraje superior a 40.000 kms por año
      def is_vehicle_km_over_40000_per_year?
        diff_year = Time.now.year - responses_translater.year
        diff_year = 1.0 if diff_year <= 0
        km_div = responses_translater.km.to_f / diff_year.to_f
        if responses_translater.vehicle_target_id == 1 and km_div > 40000
          true
        else
          false
        end
      end
      
      # 19 | Vehículo descapotable
      def is_convertible_vehicle?
        if responses_translater.convertible_vehicle == 'si'
          true 
        else
          false
        end     
      end 
            
      # 21 | Vehículo liviano con antigüedad mayor a 15 años
      def is_lightweight_vehicle_age_over_15_years?
        if is_lightweight_vehicle? and (Time.now.year - self.vehicle_year)  > 15
          true
        else
          false
        end        
      end

      # 22 | Vehículo pesado con antigüedad mayor a 20 años
      def is_heavyweight_vehicle_age_over_20_years?
        if is_heavyweight_vehicle? and (Time.now.year - self.vehicle_year)  > 20
          true
        else
          false
        end        
      end

      #  23 | Vehículos con airbag explotados o detonados
      def is_airbag_busted?
        if responses_translater.airbag_busted == 'si'
          true 
        else
          false
        end
      end
      
      # 24 | Vehículos con hologramas, pinturas especiales, adhesivos no originales
      def is_vehicle_with_holograms?
        if responses_translater.vehicle_with_holograms == 'si'
          true 
        else
          false
        end
      end

      #28 | Vehículos livianos: La sumatoria de daños supera 12 UF o tiene más de 10 daños
      def is_lightweight_vehicle_and_over_10_damages?
        if is_lightweight_vehicle? and (damages.count > 10 or damages.sum(:deductible).to_f > 12)
          true 
        else
          false
        end
      end      

      #29 | Vehículos pesados: La sumatoria de daños supera 24 UF o tiene más de 3 daños      
      def is_heavyweight_vehicle_and_over_3_damages?
        if is_heavyweight_vehicle? and (damages.count > 3 or damages.sum(:deductible).to_f > 24)
          true 
        else
          false
        end        
      end

      def without_checklist?
        # Turn true if all checklist are false
        results = self.vehicle_check_lists.map {|obj| obj.value }.uniq
        if results.size == 1 and results[0] == false # all are falses
          return true
        else
          return false
        end
      end

      def data
        <<-JSON
          {
            "Permiso": {
              "IdIngresoUsuario": "#{id_ingreso_usuario}",
              "RutUsuario": #{rut_usuario},
              "IdUsuario": #{id_usuario},
              "Ip": "",
              "Origen": 1
            },
            "IdInspeccion": #{self.id_inspection},
            "SinChecklist": #{without_checklist?}

            #{vehicle_check_lists_data}
          }
        JSON
      end

      def vehicle_check_lists_data
        unless @vehicle_check_lists_data
          @vehicle_check_lists_data = <<-JSON        
            ,"Checklist": [
          JSON

          vehicle_check_lists_array = []
          self.vehicle_check_lists.each do |vehicle_check_list|
            vehicle_check_lists_array << <<-JSON
              {
                "IdChecklist":#{vehicle_check_list.check_list_id},
                "Opcion":#{vehicle_check_list.value.to_s},     
                "Observacion":""
              }
            JSON
          end

          @vehicle_check_lists_data << vehicle_check_lists_array.join(",")
          @vehicle_check_lists_data << "]"

        end
        @vehicle_check_lists_data
      end

      def _old_data
        <<-JSON
          {
            "Permiso": {
              "IdIngresoUsuario": "#{id_ingreso_usuario}",
              "RutUsuario": #{rut_usuario},
              "IdUsuario": #{id_usuario},
              "Ip": "",
              "Origen": 1
            },
            "IdInspeccion": #{self.id_inspection},
            "SinChecklist": #{without_checklist?},
            "Checklist":[
            {
                        "IdChecklist":29,
                        "Opcion":#{is_heavyweight_vehicle_and_over_3_damages?},     
                        "Observacion":""
            },
            {
                        "IdChecklist":28,
                        "Opcion":#{is_lightweight_vehicle_and_over_10_damages?},
                        "Observacion":""
            },
            {
                        "IdChecklist":27,
                        "Opcion": false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":26,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":25,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":24,
                        "Opcion":#{is_vehicle_with_holograms?},
                        "Observacion":""
            },
            {
                        "IdChecklist":23,
                        "Opcion":#{is_airbag_busted?},     
                        "Observacion":""
            },
            {
                        "IdChecklist":22,
                        "Opcion":#{is_heavyweight_vehicle_age_over_20_years?},
                        "Observacion":""
            },
            {
                        "IdChecklist":21,
                        "Opcion":#{is_lightweight_vehicle_age_over_15_years?},     
                        "Observacion":""
            },
            {
                        "IdChecklist":20,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":19,
                        "Opcion":#{is_convertible_vehicle?},     
                        "Observacion":""
            },
            {
                        "IdChecklist":18,
                        "Opcion":#{is_vehicle_km_over_40000_per_year?},
                        "Observacion":""
            },
            {
                        "IdChecklist":17,
                        "Opcion":#{is_heavyweight_and_comercial_vehicle?},     
                        "Observacion":""
            },
            {
                        "IdChecklist":16,
                        "Opcion":#{is_lightweight_and_comercial_vehicle?},
                        "Observacion":""
            },
            {
                        "IdChecklist":15,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":14,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":13,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":12,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":11,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":10,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":9,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":8,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":7,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":6,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":5,
                        "Opcion": #{is_chassis_number_adulterated?},     
                        "Observacion":""
            },
            {
                        "IdChecklist":4,
                        "Opcion":#{is_tire_flat?},
                        "Observacion":""
            },
            {
                        "IdChecklist":3,
                        "Opcion":false,     
                        "Observacion":""
            },
            {
                        "IdChecklist":2,
                        "Opcion":false,
                        "Observacion":""
            },
            {
                        "IdChecklist":1,
                        "Opcion":#{is_capot_unable_to_open?},     
                        "Observacion":""
            }
            ]
          } 
        JSON
      end

      
    end
  end
end

=begin
 
 
 1  | Capot o Maletero no abren
 2  | Carrocería (modificaciones que alteran el rendimiento para competición y/o uso del vehículo)
 3  | Motor (modificaciones que alteran el rendimiento para competición y/o uso del vehículo)
 4  | Neumáticos lisos
 5  | Nº de chasis no se puede validar
 6  | No tiene patente (salvo vehículos nuevos con máximo 5 días hábiles)
 7  | Pérdida Total
 8  | Reparación anterior evidentemente mal realizada
 9  | Vehículo cuerpo diplomático
 10 | Vehículo de arriendo (Rent a Car)
 11 | Vehículo de emergencia (bomberos, carabineros, ambulancia, etc.)
 12 | Vehículo de escuela de conductores
 13 | Vehículo de importación directa o retornado
 14 | Vehículo de locomoción colectiva (taxi, uber o colectivo)
 15 | Vehículo de suscripción restringida
 16 | Vehículo de uso comercial liviano
 17 | Vehículo de uso comercial pesado (camión o bus)
 18 | Vehículo de uso particular con kilometraje superior a 30.000 kms por año
 19 | Vehículo descapotable
 20 | Vehículo furgón escolar
 21 | Vehículo liviano con antigüedad mayor a 15 años
 22 | Vehículo pesado con antigüedad mayor a 20 años
 23 | Vehículos con airbag explotados o detonados
 24 | Vehículos con hologramas, pinturas especiales, adhesivos no originales
 25 | Vehículos con patente de otro color (no blanca)
 26 | Vehículos de 3 o menos ruedas
 27 | Vehículos ingresados por franquicia aduanera
 28 | Vehículos livianos: La sumatoria de daños supera 12 UF o tiene más de 10 daños
 29 | Vehículos pesados: La sumatoria de daños supera 24 UF o tiene más de 3 daños
  

=end