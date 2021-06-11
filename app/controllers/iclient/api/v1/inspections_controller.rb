module Iclient
  module Api::V1
    class InspectionsController < ApplicationController

      include HttpBasicAuth
      before_action :http_authenticate!, only: :destroy   
      
      def index
        render json: {hola: 'mundo'}
      end
  
      def create
        inspection_builder = ::Iclient::InspectionBuilder.new(data: inspection_params)
        inspection_builder.create_inspection
        http_code = case inspection_builder.result[:type]
        when :validation
          422
        when :exception
          500
        else
          200
        end
        render json: inspection_builder.result, status: http_code
      end
  
      def destroy
        mission_id = params[:id]
        begin
          Iclient::Inspection.where(mission_id: params[:id]).destroy_all
        rescue => exception
          #  TODO: Notify slack on failing removing
          puts "No se puedo eliminar la inspección con MISSION_ID #{params[:id]} #{exception.message}"          
        end
        render json: {}
      end
  
      private
      def inspection_params
        params.require(:data).permit(
          inspection: [
            :mission_id,
            :insurance_broker_id,
            :insurance_inspector_id,
            :inspection_type_id,
            :inspection_origin_id,
            :address,
            :commune_description,
            :client_rut,
            :client_rut_vd,
            :insured_first_name,
            :insured_last_name,
            :insured_mother_last_name,
            :contact,
            :phone_number,
            :email,
            :vehicle_brand_description,
            :vehicle_model_description,
            :patent,
            :additional_instruction,
            :inspection_date,
            :campain_id,
            :is_clone,
            :original_mission_id,
            :request_id,
            :vehicle_year
          ]
        )
      end    
  
    end
  end
end

=begin
curl -X GET \
-H "Accept:application/vnd.fid.v1+json" \
http://localhost:3000/iclient/api/inspections | jq . -C 


=end