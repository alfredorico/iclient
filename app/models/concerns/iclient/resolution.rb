module Iclient
  module Resolution
    extend ActiveSupport::Concern
      # Resolution methods ----------------------------------------------------
    def disapproved_by_checklists?
      raise "disapproved_by_checklists?: No hay checklists calculados para esta inspección (id #{self.id}). Debe ejecutar primero Inspection::Iclient.find(#{self.id}).update_data" unless vehicle_check_lists.any?
      vehicle_check_lists.where("check_list_id in (19,28,29,2,3,8,10,11,12,13,14,20,23,26,1,6,4,18,25) and value is true ").any?
    end

    def rejected_by_checklists?
      raise "rejected_by_checklists?: No hay checklists calculados para esta inspección (id #{self.id}). Debe ejecutar primero Inspection::Iclient.find(#{self.id}).update_data" unless vehicle_check_lists.any?
      vehicle_check_lists.where("check_list_id in (21,22,5) and value is true").any?
    end

    def approved_by_checklist?
      !rejected_by_checklists? and !disapproved_by_checklists?
    end

    def sent_resolution_email
      if  [1449, 1992, 1992].include?(self.campain_id) and (self.workflow_step == 'resolved' or self.rejected_by_iclient_validation_service == true or rejected_by_checklists?)
        ::Iclient::Mailer.resolution_email(id: self.id).deliver_later
      end
    end

    def resolution_text
      if disapproved_by_checklists?
        "REPROBADA"
      elsif self.rejected_by_iclient_validation_service == true
        "RECHAZAZA"
      elsif rejected_by_checklists?
        "RECHAZAZA"
      else
        "APROBADA"
      end
    end

  end
end


