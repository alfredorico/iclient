module Iclient
  module ApiTalkers
    class ResponsesTranslater
      attr_reader :mission_id
  
      def initialize(mission_id:)
        @mission_id = mission_id
      end
  
      def has_responses?
        responses_by_id.any?
      end
  
      def inspection_successfully?
        responses_by_id['¿tuviste éxito en la inspección ?'].try(:downcase) == 'si'
      rescue => e
        puts "ERROR  inspection_successfully?: #{e.message}"       
      end
  
      def inspection_failed?
        responses_by_id['¿tuviste éxito en la inspección ?'].blank? or responses_by_id['¿tuviste éxito en la inspección ?'].try(:downcase) == 'no'
      rescue => e
        puts "ERROR inspection_failed?: #{e.message}"       
      end
  
      # Vehicle responses ---------------------------------------------
      def transmission_id
        # form_component_id "5e162a80fffbe97f5cdc278b" tipo de transmision
        {
          'automática' => 1,
          'mecánica (manual)' => 2
        }[responses_by_id["tipo de transmisión del vehículo"].downcase]   
      rescue => e
        puts "ERROR vehicle.transmission_id: #{e.message}"    
      end
  
      def vehicle_target_id
        # form_component_id "5e162a7efffbe97f5cdc275c" Uso del vehículo
        vehicle_target_id = {
          'particular' => 1,
          'comercial' => 2
        }[responses_by_id["uso del vehículo"].downcase]     
        if vehicle_target_id.present?
          vehicle_target_id
        else
          1
        end
      rescue => e
        puts "ERROR vehicle.vehicle_target_id: #{e.message}"   
      end
  
      def year
        # form_component_id 5d8e3ef5fffbe947dfc15622 año del vehículo
        responses_by_id["año del vehículo"].to_i
      rescue => e
        puts "ERROR vehicle.year: #{e.message}"      
      end
  
      def km
        # form_component_id 5e162a7ffffbe97f5cdc2774 kilometraje
        responses_by_id["kilometraje del vehículo"].to_i
      rescue => e
        puts "ERROR vehicle.km: #{e.message}"      
      end
  
      def color
        _color = responses_by_id["color del vehículo"]&.downcase&.strip
        if _color == "amarillo/negro"
          "amarillo"
        else
          _color
        end
      rescue => e
        puts "ERROR vehicle.color_id: #{e.message}"  
      end
  
      def inspection_failed_reason
        responses_by_id["¿por qué no tuviste éxito?"]&.downcase&.strip
      end

      def vehicle_type_id
        vehicle_type = responses_by_id["tipo de vehículo"]&.strip
        ::Iclient::VehicleType.where("upper(unaccent(description)) = upper(unaccent('#{vehicle_type}'))").first.id
      rescue => e
        message = "ERROR en mission_id #{mission_id} vehicle_type: '#{vehicle_type}' error: #{e.message}"        
        puts message
        raise message
      end
  
      def comment
        _comentario = responses_by_id["comentario"].to_s[0..250]
        if _comentario.present?
          _comentario = _comentario.gsub("\"","")
          _comentario = _comentario.gsub("\n","")
          _comentario
        else
          nil
        end
      end
  
      def vehicle_accessories
        # iterate over parts
        unless @vehicle_accessories
          @vehicle_accessories = []
          if responses_by_id['accesorios del vehículo'].present? and responses_by_id['accesorios del vehículo'].any? # form_component_id 5e162a80fffbe97f5cdc2790 
            responses_by_id['accesorios del vehículo'].each do |_vehicle_accessory|
              vehicle_accessory = {
              }
              @vehicle_accessories << vehicle_accessory
            end
          end
        end
        @vehicle_accessories        
      end
      
      def damages
        # iterate over parts
        unless @damages
          @damages = []
          if responses_by_id['daños del vehículo'].present? and responses_by_id['daños del vehículo'].any? # form_component_id 5e162a80fffbe97f5cdc2790 
            responses_by_id['daños del vehículo'].each do |_vehicle_part|
              begin
                _damage_type_form_component_id = vehicle_parts_correlations[_vehicle_part[:text].downcase][:damage_type_form_component_id]
                vehicle_part_id = vehicle_parts_correlations[_vehicle_part[:text].downcase][:id]
                perspective_id = vehicle_parts_correlations[_vehicle_part[:text].downcase][:perspective_id]
                damage_severity_id = if ::Iclient::VehiclePart.find(vehicle_part_id).exclude_deductible 
                  'E' # if vehicle part is damaged and marked as exclude for deductible then set 'E' as severity
                else
                  damage_types_correlations[responses_by_id[_damage_type_form_component_id].downcase][:damage_severity_id]
                end
                damage = {
                  vehicle_part_id: vehicle_part_id,
                  damage_type_id: damage_types_correlations[responses_by_id[_damage_type_form_component_id].downcase][:id],
                  damage_severity_id: damage_severity_id,
                  perspective_id: perspective_id
                }
              rescue => e
                msj = "Error al procesar los daños al parsear #{_vehicle_part[:text]}: #{e.message}"
                puts msj
                raise msj
              end
              @damages << damage
            end
          end

          if airbag_busted == 'si' # or airbag_light_on == 'si'
            @damages << {
              vehicle_part_id: 78,
              damage_type_id: 3,
              damage_severity_id: 'E', # Exclude airbag detoned
              perspective_id: 16
            }            
          end

        end
        @damages
      end
      
      def vehicle_parts_correlations
        {
          'máscara' => {damage_type_form_component_id: 'tipo de daño en máscara',id: 5, perspective_id: 5}, # Mascara
          'tapiz' => {damage_type_form_component_id: 'tipo de daño del tapiz',id: 117, perspective_id: 5}, # Tapiz
          'pintura en general' => {damage_type_form_component_id: 'tipo de daño en pintura en general',id: 11, perspective_id: 5}, # Pintura
          'espejo derecho' => {damage_type_form_component_id: 'tipo de daño del espejo derecho',id: 16, perspective_id: 9}, # Espejo Lateral Derecho
          'espejo izquierdo' => {damage_type_form_component_id: 'tipo de daño del espejo izquierdo',id: 16, perspective_id: 10}, # Espejo Lateral Izquierdo
          'capot' => {damage_type_form_component_id: 'tipo de daño del capot',id: 3, perspective_id: 5}, # Capot
          'foco delantero' => {damage_type_form_component_id: 'tipo de daño del foco delantero',id: 14, perspective_id: 8}, # Foco Frontal Derecho
          'foco trasero' => {damage_type_form_component_id: 'tipo de daño del foco trasero',id: 14, perspective_id: 11}, # Foco Posterior Derecho
          'manillas' => {damage_type_form_component_id: 'tipo de daño en manillas',id: 123, perspective_id: 25}, # Manillas Exteriores Lateral DD
          'molduras' => {damage_type_form_component_id: 'tipo de daños en molduras',id: 103, perspective_id: 25}, # Molduras Lateral DD
          'parabrisa delantero' => {damage_type_form_component_id: 'tipo de daños en parabrisa delantero',id: 15, perspective_id: 8}, # Parabrisa
          'parabrisa trasero' => {damage_type_form_component_id: 'tipo de daños en parabrisas trasero',id: 15, perspective_id: 11}, # Luneta
          'parachoque delantero' => {damage_type_form_component_id: 'tipo de daño en parachoques delantero',id: 4, perspective_id: 8}, # Parachoque Frontal
          'parachoque trasero' => {damage_type_form_component_id: 'tipo de daño en parachoques trasero',id: 4, perspective_id: 11}, # Parachoque Posterior
          'puerta derecha' => {damage_type_form_component_id: 'tipo de daño en puerta derecha',id: 6, perspective_id: 9}, # Puerta Lateral DD
          'puerta izquierda' => {damage_type_form_component_id: 'tipo de daño en puerta izquierda',id: 6, perspective_id: 10}, # Puerta Lateral DI
          'maleta' => {damage_type_form_component_id: 'tipo de daño en la maleta',id: 10, perspective_id: 5}, # Tapa Maleta
          'tapabarro derecho' => {damage_type_form_component_id: 'tipo de daño en tapabarro derecho',id: 2, perspective_id: 9}, # Tapabarro Lateral Derecho
          'tapabarro izquierdo' => {damage_type_form_component_id: 'tipo de daño en tapabarro izquierdo',id: 2, perspective_id: 10}, # Tapabarro Lateral Izquierdo43
          'vidrio derecho' => {damage_type_form_component_id: 'tipo de daño del vidrio derecho',id: 19, perspective_id: 9}, # Vidrio Latera DD
          'vidrio izquierdo' => {damage_type_form_component_id: 'tipo de daño del vidrio izquierdo',id: 19, perspective_id: 10}, # Vidrio Latera DI
          'techo' => {damage_type_form_component_id: 'tipo de daño del techo',id: 8, perspective_id: 5}, # Techo
          'otro' => {damage_type_form_component_id: 'tipo de daño de otra pieza',id: 120, perspective_id: 5}, # Otros TWEETER 
          'tablero instrumentos' => {damage_type_form_component_id: 'tipo de daño en tablero de instrumentos',id: 61, perspective_id: 5}, # Otros      
          'alfombras' => {damage_type_form_component_id: 'tipo de daño de la alfombra',id: 83, perspective_id: 25} # Otros      
        }
      end
  
    def damage_types_correlations
      {
        'abolladura leve (menor al 10% de la pieza)' => {id: 1, damage_severity_id: 'L'},
        'abolladura media (entre 10% y 40% de la pieza)' => {id: 1, damage_severity_id: 'M'},
        'corrosión / oxidación' => {id: 5, damage_severity_id: 'E'},
        'desgaste leve (menor al 10% de la pieza)' => {id: 12, damage_severity_id: 'L'},
        'desgaste medio  (entre 10% y 40% de la pieza)' => {id: 12, damage_severity_id: 'M'},
        'faltante' => {id: 7, damage_severity_id: 'E'},
        'pintura deteriorada' => {id: 9, damage_severity_id: 'M'},
        'rayadura leve (menor al 10% de la pieza)' => {id: 2, damage_severity_id: 'L'},
        'rayadura media  (entre 10% y 40% de la pieza)' => {id: 2, damage_severity_id: 'M'},
        'rotura' => {id: 3, damage_severity_id: 'E'},
        'saltaduras' => {id: 11, damage_severity_id: 'L'},
        'trizadura' => {id: 4, damage_severity_id: 'E'}
      }
    end      

      def general_observation
        responses_by_id["comentario"].to_s[0..250] || 'sin observaciones'
      end
      
      def chassis_number
        responses_by_id["número de chasis o vin"]
      end

      def motor_number
        responses_by_id["número de motor"]
      end
      
      def correct_patent
        responses_by_id["indique la patente correcta"]        
      end

      # For checklists and damages
      # ------------------------------------
      def airbag_busted
        if responses_by_id["airbag reventado"] != false
          responses_by_id["airbag reventado"]&.downcase&.strip
        end
      end

      def airbag_light_on
        if responses_by_id["luz testigo del airbag está encendida"] != false
          responses_by_id["luz testigo del airbag está encendida"]&.downcase&.strip
        end
      end

      def chassis_number_adulterated
        responses_by_id["¿el número de chasis o vin está adulterado en el vehículo inspeccionado?"]&.downcase&.strip
      end      

      def convertible_vehicle
        responses_by_id["auto convertible"]&.downcase&.strip
      end

      def vehicle_with_holograms
        responses_by_id["vehículo cuenta con publicidad"]&.downcase&.strip
      end
      # ---------------------
      
      # For accessories -----------------
      def airbag_present
        responses_by_id["¿vehículo cuenta con airbag?"]&.downcase&.strip
      end

      def capota_type
        responses_by_id["tipo de capota"]&.downcase&.strip
      end

      def front_tire_state 
        responses_by_id["estado de los neumáticos delanteros"]&.downcase&.strip
      end

      def front_tire_worn?
        front_tire_state == 'lisos'        
      end

      def rear_tire_state 
        responses_by_id["estado de los neumáticos traseros"]&.downcase&.strip
      end

      def rear_tire_worn?
        rear_tire_state == 'lisos'        
      end

      def spare_tire 
        responses_by_id["vehículo tiene la rueda de repuesto"]&.downcase&.strip
      end

      def spare_tire_cover 
        responses_by_id["cubierta rueda de repuesto"]&.downcase&.strip
      end
      
      def radio_type
        responses_by_id["tipo de radio"]&.downcase&.strip
      end

      def selected_vehicle_accessories
        unless @selected_vehicle_accessories
          @selected_vehicle_accessories = responses_by_id["accesorios del vehículo"] || []
          @selected_vehicle_accessories.map! {|a| a[:text]&.downcase }
        end
        @selected_vehicle_accessories
      end

      def upholstery_type
        responses_by_id["tipo de tapicería"]&.downcase&.strip
      end      
      # ----------------------------------

      def inspection_failed_photo
        responses_by_id["fotografía fachada"] || responses_by_id["vehículo sucio (tierra/polvo/barro)"] || 'https://doc-extras.s3.amazonaws.com/default.png'
      rescue
        puts "ERROR getting 'inspection_failed_photo'"
        'https://doc-extras.s3.amazonaws.com/default.png'
      end

      def company_api_responses
        @company_api_responses ||= JSON.parse(
          HTTParty.get( 
            "#{ENV['COMPANY_URL']|| 'http://localhost:3000'}/api/missions/#{self.mission_id}/responses",
            {
              headers: Constants.company_auth_headers
            }
          ).body ,
          symbolize_names: true
        )
      rescue => e
        puts "Error en obtener respuestas: #{e.message}"
        {}                          
      end
  
      def responses_by_id
        @responses_by_id ||= company_api_responses.inject({}) do |mem, hash|
          if hash[:value].is_a?Hash
            mem[hash[:form_component][:label].downcase] = hash[:value][:text]
          else
            mem[hash[:form_component][:label].downcase] = hash[:value]
          end   
          mem
        end
      end     
  
    end
  end
end

=begin
rt = ApiTalkers::ResponsesTranslater.new(mission_id: Inspection.first.mission_id)
rt.transmission_id
rt.vehicle_target_id
rt.year
rt.km
rt.color
rt.observation
rt.damages
=end