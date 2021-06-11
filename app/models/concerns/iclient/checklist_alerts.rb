module Iclient
  module ChecklistAlerts
    extend ActiveSupport::Concern
      # Resolution methods ----------------------------------------------------
    def notify_on_slack_for_checklist_activated
      checklists_activated = vehicle_check_lists.where("check_list_id in (19,28,29,2,3,8,10,11,12,13,14,20,23,26,1,6,4,18,25,21,22,5) and value is true ").pluck(:check_list_id)
      if checklists_activated.any? and DateTime.now.hour > 8 and DateTime.now.hour < 21 and DateTime.now.wday != 0 and DateTime.now.wday != 6
        checklists_descriptions = ::Iclient::CheckList.where(id: checklists_activated).pluck(:description).join("\n * ")
        begin
          managers = ENV["SLACK_USERS_CHECKLIST_ALERTS"] || "<@UKA45KN4T> <@UEJSPHDTM>"
          ::SlackNotifier::CompanyQA.ping("#{managers} revisar los siguientes checklists activados para la inspección compara/iclient <http://company.com/admin/missions#/show_mission/#{self.mission_id}|#{self.mission_id}> :\n * #{checklists_descriptions}")
        rescue => e
          puts "FALLA EN NOTIFICACION SLACK DE CHECKLISTS ENCENDIDOS #{e.message}"
        end
      end
    end

  end
end


