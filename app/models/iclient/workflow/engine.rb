module Iclient
  module Workflow
    class Engine
      attr_reader :current_state

      def initialize(current_state:)
        @current_state = current_state.to_sym
        @inject_done = false
      end
  
      def inspections_for_next_step
        # For a current state, this method will give you inspections for next step to be transmitted
        @inspections_for_next_step ||= case current_state
        when :received
          Iclient::ApiTalkers::InspectionNotifier.with_workflow_step(:received)
        when :requested, :precoordinated 
          Iclient::ApiTalkers::StateNotifier.with_workflow_step(current_state)
        when :coordinated 
          Iclient::ApiTalkers::AccessoriesNotifier.with_workflow_step(:coordinated)
        when :failed 
          Iclient::ApiTalkers::StateNotifier.with_workflow_step(:failed)
        when :accessories_transmitted 
          Iclient::ApiTalkers::DamagesNotifier.with_workflow_step(:accessories_transmitted)
        when :damages_transmitted 
          # If current state is :damages_transmitted, then search all verificaction in this state, but
          # transmission behaviour is for transmit attachments
          Iclient::ApiTalkers::AttachmentsNotifier.with_workflow_step(:damages_transmitted)
        when :attachments_transmitted 
          Iclient::ApiTalkers::InspectionNotifier.with_workflow_step(:attachments_transmitted)
        when :inspection_updated 
          Iclient::ApiTalkers::ChecklistNotifier.with_workflow_step(:inspection_updated)
        when :checklist_transmitted 
          Iclient::ApiTalkers::StateNotifier.with_workflow_step(:checklist_transmitted)
        else
          []
        end
      end
  
      def notify_next_step
        unless @inject_done
          @inject_done = true
          inspections_for_next_step.each do |inspection|
            begin
              # First update inspection data
              inspection.update_data

              if inspection.can_request?
                fire(inspection) do |i|
                  i.request
                end 
              elsif inspection.can_precoordinate?
                fire(inspection) do |i|
                  i.precoordinate
                end
              elsif inspection.can_coordinate?
                fire(inspection) do |i|
                  i.coordinate
                end                
              elsif inspection.can_tofail?
                # Due to forking in flow, it must fail and notify inmediatly
                Iclient::ApiTalkers::StateNotifier.find(inspection.id).notify
                inspection.reload
                if inspection.successfully_notify
                  inspection.tofail
                end
              elsif inspection.can_transmit_damages?
                fire(inspection) do |i|
                  i.transmit_damages
                end                
              elsif inspection.can_transmit_attachments?
                fire(inspection) do |i|
                  i.transmit_attachments
                end                 
              elsif inspection.can_transmit_accessories?
                fire(inspection) do |i|
                  i.transmit_accessories
                end                   
              elsif inspection.can_update_inspection?
                fire(inspection) do |i|
                  i.update_inspection
                end                  
              elsif inspection.can_transmit_checklist?
                fire(inspection) do |i|
                  i.transmit_checklist
                end                  
              elsif inspection.can_resolve?
                fire(inspection) do |i|
                  i.resolve
                end
              end
            rescue => e
              inspection.update( 
                successfully_notify: false,
                unexpected_exception: true, 
                unexpected_exception_message: e.message
              )              
              puts "EXCEPCION EN FLUJO  mission_id: #{inspection.mission_id} MENSAJE: #{e.message}"
            end
          end          
        end
        @inject_done
      end
  
      def fire(inspection)
        inspection.notify
        inspection.reload
        if inspection.successfully_notify
          yield(inspection) # change to next state only if transmission successfuly
        end        
      end

    end
  end
end