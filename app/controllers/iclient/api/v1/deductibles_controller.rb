module Iclient
  module Api::V1
    class DeductiblesController < ApplicationController
      def index
        inspection = Inspection.where(mission_id: params[:mission_id]).first
        if inspection
          damages = inspection.damages.map do |damage|
            {
              part: "#{damage.vehicle_part.description} - #{damage.perspective.description}",
              damage_type: damage.damage_type.description,
              damage_severity: damage.damage_severity.description,
              gama: (::Iclient::VehicleBrand::GAMAS[inspection.vehicle_brand.gama] || 'SIN CLASIFICAR'),
              deductible: damage.deductible  
            }
          end
          render json: damages
        else
          render json: []
        end
      end
    end
  end
  
end