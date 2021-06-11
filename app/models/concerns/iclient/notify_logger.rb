module Iclient
  module NotifyLogger
    extend ActiveSupport::Concern
    def notify_log(show_data: true)
      puts "\n\n--------------------------------"
      puts "INSPECCIÓN: #{self.mission_id}"
      puts "PATENTE: #{self.patent}"
      puts "ID SOLICITUD: #{self.id_inspection}"
      puts "Estado actual: #{self.workflow_step}"
      if show_data
        puts "\nData transmitida:" 
        puts "=================="
        puts data
      end
      puts "\nRespuesta:"
      puts "==========="
      puts @response.body
    end
  end
end