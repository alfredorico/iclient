module Iclient
  module InspectionCloningManagement
    extend ActiveSupport::Concern

    included do
      after_create :handling_cloning
    end
    
    private
    def handling_cloning
      if self.campain_id == 1450 # Only Compara-Iclient Campain id 1450. For direct integration Iclient Company, every inspection must be done
        if self.is_clone
          ActiveRecord::Base.transaction do
            if self.original_mission_id.present?
              original_inspection = ::Iclient::Inspection.where(mission_id: self.original_mission_id).first
              if ['resolved','failed','invalidated', 'discarded', 'paused' ].exclude?(original_inspection.workflow_step)
                self.update( 
                  id_inspection: original_inspection.id_inspection,
                  workflow_step: original_inspection.workflow_step  
                ) 
                original_inspection.invalidate  
              end
            end
          end
        end
      end
    end
    
  end
end