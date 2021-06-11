module Iclient
  module ApiTalkers
    class DamagesResponseBuilder < Inspection
  
      HIGH_GAMMA = [
        "ACA"
      ]

      MEDIUM_GAMMA = [
        "FORD"
      ]

      LOW_GAMMA = [
        "CHEVROLET"
      ]

      def no_damages?
        damages.none?
      end

      def data
        <<-JSON
          {
            "IdInspeccion": #{self.id_inspection},
            "SinDanos": #{no_damages?},
            "Observacion": "Sin observacion",
            "Permiso": {
                "IdIngresoUsuario": "#{id_ingreso_usuario}",
                "RutUsuario": #{rut_usuario},
                "IdUsuario": #{id_usuario},
                "Ip": "",
                "Origen": 1
            }
            #{damage_data}
          }
        JSON
      end
      
      def damage_data
        unless no_damages?
          json = <<-JSON        
            ,"Danos": [
          JSON
          damages_array = []
          damages.each do |damage|
            damages_array << <<-JSON        
              {
                "Idpartepieza": #{damage.vehicle_part_id },
                "IdPerspectiva": #{damage.perspective_id },
                "IdDano": #{damage.damage_type_id},
                "Deducible": #{damage.deductible}
              }
            JSON
          end
          json << damages_array.join(",")
          json << "]"
        end
      end

      
    end
  end
end