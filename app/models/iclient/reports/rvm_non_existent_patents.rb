module Iclient
  module Reports
    class RvmNonExistentPatents
      def initialize
      end

      def query_result
        sql = <<-SQL
          select 
            mission_id, patent, vt.description vehicle_type, vehicle_brand_description, vehicle_model_description, vehicle_year, vehicle_color, motor_number, chassis_number
          from iclient_inspections c
          inner join iclient_vehicle_types as vt on vt.id = vehicle_type_id
          where successfully_notify is false 
          and response_message_extra ilike '%No se identifica en RVM%'
          and workflow_step not in ('discarded','invalidated','paused')
          and inspection_successfully is true           
          order by c.created_at;
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
          worksheet.append_row ['PATENTE','TIPO','MARCA','MODELO','AÑO','COLOR','MOTOR','CHASIS']
          query_result.each do |hash|
            worksheet.append_row [hash['patent'],hash['vehicle_type'],	hash['vehicle_brand_description'],	hash['vehicle_model_description'],	hash['vehicle_year'], hash['vehicle_color'],	hash['motor_number'],	hash['chassis_number']]
          end
          @report_file = workbook.read_string      
        end
        @report_file
      end

      def save_report_file
        File.open('patentes_no_existentes_en_rvm.xlsx', 'wb') {|f| f.write(report_file) }      
      end

      def padrones
        unless @padrones
          @padrones = query_result.map do  |h|
            rt = ::Iclient::ApiTalkers::ResponsesTranslater.new(mission_id: h['mission_id'])
            {
              patent: h['patent'],
              padron_front: rt.responses_by_id["foto frontal del padrón"],
              padron_rear: rt.responses_by_id["foto posterior del padrón"]
            }
          end          
        end
        @padrones
      end    

    end  
  
  end
end