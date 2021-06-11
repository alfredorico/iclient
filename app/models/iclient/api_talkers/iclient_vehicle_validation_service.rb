module Iclient
  module ApiTalkers
    class IclientVehicleValidationService < Inspection
      
      def validate_with_service!
        if inner_description&.downcase&.include?("vehículo no asegurable") and (valid_flag == '1' or valid_flag == '2')
          update(
            rejected_by_iclient_validation_service: true
          )          
          SlackNotifier::CompanyTI.ping ":warning: <@U6NBF7DKN> Servicio de validación iclient para la Patente #{self.patent&.strip} y la inspección #{self.mission_id} indicó: #{inner_description} / código: #{valid_flag}"
          disapprove_in_company
        end
      end

      def inner_description
        iclient_service.at("DescripcionInterna").content
      rescue => e
        record_exception ":warning: <@U6NBF7DKN> Error en para misión IclientVehicleValidationService#inner_description para mission #{self.mission_id}: #{e.message}"
        nil
      end      

      def valid_flag
        iclient_service.at("Valido").content
      rescue => e
        record_exception ":warning: <@U6NBF7DKN> Error en para misión IclientVehicleValidationService#valid_flag para mission #{self.mission_id}: #{e.message}"
        nil
      end

      def iclient_service
        unless @iclient_service
          url = "http://www11.iclient.cl/Corporate/Web/MobileService/external.asmx/Valida_Vehiculo_Iclient?Clave=#{ENV['PASSWORD_VALIDA_ICLIENT']}&patente=#{self.patent&.strip}"
          @response = HTTParty.get(url)
          @iclient_service = Nokogiri::XML(@response.body)
          if @response.code != 200
            raise "Servicio de Validación de Iclient devolvió HTTP #{@response.code} / Body: #{@response.body}"
          end
        end
        @iclient_service
      rescue => e
        record_exception ":warning: <@U6NBF7DKN> Falla en IclientVehicleValidationService#iclient_service  para misión #{self.mission_id}: #{e.message}"
      end

      def disapprove_in_company
        begin
          @response = ::HTTParty.send(:put, ("#{ENV['COMPANY_URL'] || 'http://localhost:3000'}/api/missions/#{self.mission_id}/disapprove"), { 
            headers: ::Iclient::Constants::company_auth_headers,
            body: {
              mission: {
                disapprove_detail: 'customer_rejects',
                disapprove_comment: "#{internal_description}. Posiblemente: Vehículo con pérdida total o diplomático"
              }
            }.to_json,
            verify: false
          })
          if @response.code == 200
            update(
              state: 'disapproved',
              sub_state: 'rejected'
            )
          else
            raise "Company devolvió HTTP #{@response.code} con body: #{@response.body} al intentar rechazar la misión"
          end
        rescue => e     
          record_exception ":warning: :scroll: <@U6NBF7DKN> Excepción al rechazar la misión en company #{self.mission_id}: #{e.message} debido a la validación instantánea de vehículo no asegurable por parte de Iclient"
        end         
      end      

      def internal_description
        iclient_service.at("DescripcionInterna").content
      rescue => e
        record_exception ":warning: <@U6NBF7DKN> Error en para misión IclientVehicleValidationService#internal_description para mission #{self.mission_id}: #{e.message}"
        nil
      end

      def record_exception(msg)
        SlackNotifier::CompanyTI.ping msg
        update( 
          sent_iclient_at: Time.now, 
          successfully_notify: false,
          unexpected_exception: true, 
          unexpected_exception_message: msg,
          http_status: nil,
          http_response_body: nil
        )
      end

    end
  end
end
