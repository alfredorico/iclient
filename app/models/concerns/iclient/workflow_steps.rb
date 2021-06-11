module Iclient::WorkflowSteps
  extend ActiveSupport::Concern

  included do

    state_machine :workflow_step, initial: :received do

      event :request do
        transition from: :received, to: :requested, if: ->(inspection) { 
          if inspection.campain_id == 1449 # Iclient
            inspection.rejected_by_iclient_validation_service == true or inspection.state == 'initial' or inspection.state == 'taken' 
          elsif [1450, 1991, 1992].include?(inspection.campain_id) # Compara, 123 seguros
            inspection.rejected_by_iclient_validation_service == true or inspection.state == 'approved'             
          end
        }
      end

      event :precoordinate do
        transition from: :requested, to: :precoordinated
      end

      event :coordinate do
        transition from: :precoordinated, to: :coordinated, if: ->(inspection) { 
          if inspection.campain_id == 1449 # Iclient
            inspection.rejected_by_iclient_validation_service == true or inspection.state == 'taken' or inspection.state == 'approved' or (inspection.state == 'disapproved')
          elsif [1450, 1991, 1992].include?(inspection.campain_id) # Compara, 123 seguros
            true             
          end
        }
      end

      # States for excluding from normal flow ------------------------------------
      # This states don't belong to normal flow secuence
      event :invalidate do # when a cloned inspection has arrived, original inspection must be invalidated
        transition from: [:received, :requested, :precoordinated, :coordinated], to: :invalidated
      end

      event :discard do # Exluding for ever
        transition all => :discarded
      end

      event :pause do # Temporary pause transmision when failing on some service
        transition all => :paused
      end
      # --------------------------------------------------------------------

      event :tofail do
        transition from: [:requested, :precoordinated, :coordinated], to: :failed, if: ->(inspection) { 
          inspection.rejected_by_iclient_validation_service == true or 
          (inspection.state == 'approved' and inspection.inspection_successfully == false) or 
          (([1449, 1991, 1992].include?(inspection.campain_id)) and inspection.state == 'disapproved') or
          (([1449, 1991, 1992].include?(inspection.campain_id)) and inspection.inspection_successfully == true and inspection.rejected_by_checklists?) # Just for iclient and ff validation iclient fails for checklist id: 21,22,5
        }
      end

      event :transmit_accessories do
        transition from: :coordinated, to: :accessories_transmitted, if: ->(inspection) { inspection.state == 'approved' and inspection.inspection_successfully == true }
      end      
      
      event :transmit_damages do
        transition from: :accessories_transmitted, to: :damages_transmitted
      end
      
      event :transmit_attachments do
        transition from: :damages_transmitted, to: :attachments_transmitted
      end

      event :update_inspection do
        transition from: :attachments_transmitted, to: :inspection_updated
      end

      event :transmit_checklist do
        transition from: :inspection_updated, to: :checklist_transmitted
      end

      # event :inspector_processing do
      #   transition from: :checklist_transmitted, to: :inspector_proccesed
      # end

      event :resolve do
        transition from: :checklist_transmitted, to: :resolved
      end

    end    
  end  
end