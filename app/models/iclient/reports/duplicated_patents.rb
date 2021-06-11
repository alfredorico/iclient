module Iclient
  module Reports
    class DuplicatedPatents
      def initialize
      end

      def query_result
        sql = <<-SQL
          select 
            patent, response_message_extra
          from iclient_inspections c
          inner join iclient_vehicle_types as vt on vt.id = vehicle_type_id
          where successfully_notify is false 
          and response_message_extra ilike '%Inspección Vehículo: Ya existe una inspección%'
          and workflow_step not in ('discarded','invalidated','paused')
          and successfully_notify is false
          order by c.created_at
        SQL
        @query_result ||= ActiveRecord::Base.connection.select_all(sql).to_a      
      end

      def any_patent?
        query_result.any?
      end

      def report_file
        unless @report_file
          workbook = FastExcel.open
          worksheet = workbook.add_worksheet
          worksheet.append_row ['PATENTE','MENSAJE']
          query_result.each do |hash|
            worksheet.append_row [hash['patent'],hash['response_message_extra']]
          end
          @report_file = workbook.read_string      
        end
        @report_file
      end

      def save_report_file
        File.open('patentes_duplicadas.xlsx', 'wb') {|f| f.write(report_file) }      
      end

    end  
  
  end
end