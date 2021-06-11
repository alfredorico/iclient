module Iclient
  module ApiTalkers
    class AccessoriesResponseBuilder < Inspection

      def responses_translater
        @responses_translater ||= ResponsesTranslater.new(mission_id: self.mission_id) 
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
            "SinAccesorios":false,
            "accesorios":[
              #{accessories_array}
            ]
          }
        JSON
      end

      def accessories_array
        self.vehicle_accessories.map do |accesory|
          if accesory.accessory_id == 6
            <<-JSON
              {
                "IdAccesorio":#{accesory.accessory_id},
                "Cantidad":1,
                "Caracteristicas":[]
              }            
            JSON
          else
            <<-JSON
              {
                "IdAccesorio":#{accesory.accessory_id},
                "Cantidad":1,
                "Caracteristicas":[
                  {
                    "IdCaracteristica": #{accesory.accessory_feature_id},
                    "Valor":"#{accesory.value || '---'}"
                  }
                ]
              }            
            JSON
          end
        end.join(',')
      end
      
    end
  end
end


=begin
{
  "IdAccesorio":9,
  "Cantidad":1,
  "Caracteristicas":[
    {
      "IdCaracteristica":91,
      "Valor":"---"
    }
  ]
},
=end