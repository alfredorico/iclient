module Iclient
  class Mailer < ::ApplicationMailer
  
    def non_existent_rvm_patents
      rvm_non_existent_patents = ::Iclient::Reports::RvmNonExistentPatents.new
      @any_patent = rvm_non_existent_patents.any_patent?
      @padrones = rvm_non_existent_patents.padrones
      if @any_patent
        attachments["patentes_no_existentes_en_rvm-#{DateTime.now.in_time_zone.strftime("%d-%m-%Y")}.xlsx"] = rvm_non_existent_patents.report_file
        mails = ENV['ICLIENT_MAILS_NON_EXISTENT_PATENT_IN_RVM'] || 'alfredorico@gmail.com'
        mail to: mails, subject: "Patentes no existentes en RVM / Compara - Company"
      end
    end

    def duplicated_patents
      duplicated_patents = ::Iclient::Reports::DuplicatedPatents.new
      @any_patent = duplicated_patents.any_patent?
      if @any_patent
        attachments["patentes-duplicadas-#{DateTime.now.in_time_zone.strftime("%d-%m-%Y")}.xlsx"] = duplicated_patents.report_file
        mails = ENV['ICLIENT_MAILS_DUPLICATED_PATENTS'] || 'alfredorico@gmail.com'
        mail to: mails, subject: "Patentes ya introducidas en Iclient"
      end
    end

    def resolution_email(id:)
      @inspection = Inspection.find(id)
      email = @inspection.email
      mail( 
        to: email, subject: "Resolución de inspección de vehículo",
        cco: 'alfredorico@gmail.com'
      )
    end
  
  end
  
end
