module Iclient
  module IclientVehicleValidation
    extend ActiveSupport::Concern

    included do
      after_create :disapprove_if_invalid_patent_from_iclient
    end
    
    private
    def disapprove_if_invalid_patent_from_iclient
      if self.campain_id == 1450 # Only Compara-Iclient Campain id 1450. For direct integration Iclient Company, every inspection must be done
        ::Iclient::ApiTalkers::IclientVehicleValidationService.find(self.id).validate_with_service!
      end
    end
    
  end
end