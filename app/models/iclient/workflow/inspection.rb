module Iclient
  module Workflow
    class Inspection
      attr_reader :mission_id, :inspection, :id, :update_data

      def initialize(mission_id: nil, id_inspection: nil, _id: nil, update_data: true)
        @mission_id = mission_id
        @update_data = update_data
        @inject_done = false
        @inspection = if _id.present?
          ::Iclient::Inspection.find(_id)
        elsif id_inspection.present?
          ::Iclient::Inspection.where(id_inspection: id_inspection).first
        elsif mission_id.present?
          ::Iclient::Inspection.where(mission_id: mission_id).first
        end
        if @inspection
          @id = @inspection.id
        else
          raise "Inspection doesn't exists in database"
        end
      end

      def notify
        
        # Update base object data previous to injection flow ---------------------------------------------------------------------------------
        begin
          @inspection.update_data if update_data
        rescue => e
          @inspection.update( 
            successfully_notify: false,
            unexpected_exception: true, 
            unexpected_exception_message: e.message
          )              
          puts "EXCEPCION ACTUALIZANDO INSPECCION mission_id: #{inspection.mission_id} PREVIO AL FLUJO DE TRANSMISIÓN: #{e.message}"
          return
        end

        # Alerting Checklist
        @inspection.notify_on_slack_for_checklist_activated
        
        # Start injection flow -------------------------------------------------------------------------------------------------------------
        begin

          if @inspection.workflow_step == 'received'
            if @inspection.can_request?
              inspection_notifier = Iclient::ApiTalkers::InspectionNotifier.find(id)
              successfully_notify = fire(inspection_notifier) do |i|
                i.request
              end 
              @inspection.reload
              return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
            end
          end

          if @inspection.workflow_step == 'requested'
            if @inspection.can_precoordinate?
              state_notifier = Iclient::ApiTalkers::StateNotifier.find(id)
              successfully_notify = successfully_notify = fire(state_notifier) do |i|
                i.precoordinate
              end
              @inspection.reload
              return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
            end
          end

          if @inspection.workflow_step == 'precoordinated'
            if @inspection.can_coordinate?
              state_notifier = Iclient::ApiTalkers::StateNotifier.find(id)
              successfully_notify = fire(state_notifier) do |i|
                i.coordinate
              end                
              @inspection.reload
              return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
            end
          end

          if @inspection.workflow_step == 'coordinated'
            if @inspection.can_tofail?
              state_notifier = Iclient::ApiTalkers::StateNotifier.find(id)
              successfully_notify = fire(state_notifier) do |i|
                i.tofail
                i.update_iclient_state_in_company # only for compara
                i.update_iclient_resolution_in_company # only for Iclient
              end                
              return if successfully_notify # importan change condition because workflow can ends here
            elsif @inspection.can_transmit_accessories?
              accessories_notifier = Iclient::ApiTalkers::AccessoriesNotifier.find(id)
              successfully_notify = fire(accessories_notifier) do |i|
                i.transmit_accessories
              end    
              @inspection.reload
              return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
            end
          end

          if @inspection.workflow_step == 'accessories_transmitted'
            if @inspection.can_transmit_damages?
              damages_notifier = Iclient::ApiTalkers::DamagesNotifier.find(id)
              successfully_notify = fire(damages_notifier) do |i|
                i.transmit_damages
              end
              @inspection.reload
              return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
            end          
          end

          if @inspection.workflow_step == 'damages_transmitted'
            if @inspection.can_transmit_attachments?
              attachments_notifier = Iclient::ApiTalkers::AttachmentsNotifier.find(id)
              successfully_notify = fire(attachments_notifier) do |i|
                i.transmit_attachments
              end
              @inspection.reload
              return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
            end          
          end

          if @inspection.workflow_step == 'attachments_transmitted'
            if @inspection.can_update_inspection?
              inspection_notifier = Iclient::ApiTalkers::InspectionNotifier.find(id)
              successfully_notify = fire(inspection_notifier) do |i|
                i.update_inspection
              end
              @inspection.reload
              unless successfully_notify 
                # Just retry for trying fixing chassis number if was typed wrong -----------------------------------------------------------------------
                inspection_notifier = Iclient::ApiTalkers::InspectionNotifier.find(id)
                successfully_notify = fire(inspection_notifier) do |i|
                  i.update_inspection
                end
                @inspection.reload  
                return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
                # ----------------------------------------------------------------------------------------------------------------------------------------------
              end
            end          
          end

          if @inspection.workflow_step == 'inspection_updated'
            if @inspection.can_transmit_checklist?
              checklist_notifier = Iclient::ApiTalkers::ChecklistNotifier.find(id)
              successfully_notify = fire(checklist_notifier) do |i|
                i.transmit_checklist
              end
              @inspection.reload
              unless successfully_notify 
                # Just retry for trying to turn on failed checklist as: pertida total (id) 7-----------------------------------------------------------------------
                checklist_notifier = Iclient::ApiTalkers::ChecklistNotifier.find(id)
                successfully_notify = fire(checklist_notifier) do |i|
                  i.transmit_checklist
                end
                @inspection.reload  
                return unless successfully_notify # return to interrupt flow if successfully_notify is false (due to service rejection or another internal exception)
                # ----------------------------------------------------------------------------------------------------------------------------------------------
              end
            end          
          end

          if @inspection.workflow_step == 'checklist_transmitted'
            if @inspection.can_resolve?
              state_notifier = Iclient::ApiTalkers::StateNotifier.find(id)
              successfully_notify = fire(state_notifier) do |i|
                i.resolve
                i.update_iclient_state_in_company # only for compara
                i.update_iclient_resolution_in_company # only for Iclient
                i.sent_resolution_email # only for Iclient
              end
              return # happy ending workflow 
            end          
          end
            
        rescue => e
          @inspection.update( 
            successfully_notify: false,
            unexpected_exception: true, 
            unexpected_exception_message: "#{e.message} #{e.backtrace[0..10].to_s}"
          )              
          puts "EXCEPCION EJECUNTADO EL FLUJO DE TRANSMISION  mission_id: #{@inspection.mission_id} PREVIO A LA TRANSMISIÓN: #{e.message} #{e.backtrace[0..10].to_s}"
          return          
        end
      end
  
      def fire(inspection_notifier)
        inspection_notifier.notify
        inspection_notifier.reload
        if inspection_notifier.successfully_notify
         yield(inspection_notifier) # change to next state only if transmission successfuly
        end
        return inspection_notifier.successfully_notify
      end

    end
  end
end