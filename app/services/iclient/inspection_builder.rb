module Iclient
  class InspectionBuilder
    attr_reader :data
  
    def initialize(data:)
      @data = data[:inspection]
    end

    def inspection_params
      unless @inspection_params
        # 1) Search commune
        @inspection_params = data
        @inspection_params[:inspection_state_id] = 1 # First state 'Solicitada'
        @inspection_params[:vehicle_target_id] = 1 # Setting target to Particular by default
        @inspection_params[:state] = :initial # Setting to Particular by default
        @inspection_params[:vehicle_type_id] = 1 # Setting type to Automovil by default
        @inspection_params[:commune_id] = Commune.where("upper(unaccent(description)) = upper(unaccent('#{@inspection_params[:commune_description]}'))").first.id
        # 2) Search vehicle brand and model
        vehicle_model = VehicleModel.where(description: @inspection_params[:vehicle_model_description], brand_description: @inspection_params[:vehicle_brand_description]).first
        if vehicle_model
          @inspection_params[:vehicle_brand_id] = vehicle_model.vehicle_brand_id
          @inspection_params[:vehicle_model_id] = vehicle_model.id
        else
          vehicle_model = VehicleModel.last
          @inspection_params[:vehicle_brand_id] = vehicle_model.vehicle_brand_id
          @inspection_params[:vehicle_model_id] = vehicle_model.id
          @inspection_params[:error_matching_brand_model] = true
        end        
      end
      @inspection_params
    end
  
    def create_inspection
      unless @inspection
        @inspection = Inspection.new(inspection_params)
        @inspection.save
      end
      @inspection    
    rescue => e 
      # InspectionFalied.create(mission_id: ....) # Suggesting this model
      Rails.logger.debug e.message
      @result = {
        type: :exception,     
        mission_id: @inspection.mission_id,
        messages: [{general: e.message}]
      }
    end
  
    def result
      unless @result
        create_inspection # just in case not called
        @inspection_errors = @inspection.errors.messages
        @result = if @inspection.errors.messages.any?
          {
            type: :validation, 
            mission_id: @inspection.mission_id,
            inspection_errors: @inspection_errors,
          }
        else
          {
            type: :succefully,
            mission_id: @inspection.mission_id,
          } 
        end
      end
      @result
    end
    
  end
  
end