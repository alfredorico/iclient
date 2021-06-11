module Iclient
  module Reports
    class SlackInspectionAlerts
      def initialize
      end

      def query_result
        sql = <<-SQL
          select 
            id, mission_id, patent, workflow_step, state, sub_state, response_message_extra rme, unexpected_exception_message uem, http_response_body hrb
          from iclient_inspections c
          where workflow_step not in (
            'invalidated', 'discarded', 'paused'
          ) and successfully_notify is false
          order by id
        SQL
        @query_result ||= ActiveRecord::Base.connection.select_all(sql).to_a      
      end

      def any_patent?
        query_result.any?
      end

      def report
        unless @report
          @report = ""
          if any_patent?
            @report << "INYECCIONES FALLIDAS: \n" 
            @report << "===================== \n\n" 
          end
          query_result.each do |hash|
            @report << "*id*: #{hash['id']}\n"
            @report << "*PATENTE*: #{hash['patent']}\n"
            @report << "*ID MISSION*: #{hash['mission_id']}\n"
            @report << "*ETAPA DE FLUJO*: #{hash['workflow_step']}\n"
            @report << "*ESTADO*: #{hash['state']}\n"
            @report << "*SUBESTADO*: #{hash['sub_state']}\n"
            @report << "*ERROR*: #{hash['rme'].to_s + " " + hash['uem'].to_s + " " + hash['hre'].to_s + " " }\n"
            @report << "------------------------------------------------------------------\n\n"
          end
        end
        @report
      end

      def notify_slack
        ::SlackNotifier::CompanyAlerts.ping(report)
      end


    end  
  
  end
end