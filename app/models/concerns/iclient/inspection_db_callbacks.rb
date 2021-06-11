module Iclient
  module InspectionDbCallbacks
    extend ActiveSupport::Concern

    included do
      before_create :tweak_data
      after_create :precoordinate_to_iclient, if: Proc.new { |i| i.campain_id == 1449  } # After creating a new inspection for iclient (campain_id 1449) inmediatly transmit it to iclient for setting precoordinate state
    end
    
    private
    def tweak_data
      self.patent = self.patent&.strip
      self.patent = self.patent&.gsub(Regexp.new("[^a-zA-Z0-9]"),"")
      if self.campain_id == 1449 # only for Iclient that skip initial step in workflow
        self.workflow_step = "requested"
        self.id_inspection = self.request_id
      end
    end

    def precoordinate_to_iclient
      Iclient::Workflow::Inspection.new(_id: id).notify
    end
    
  end
end