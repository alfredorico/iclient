module Iclient::CompanyInspection
  extend ActiveSupport::Concern

  def inspection_state
    inspection[:state].to_sym
  rescue
    nil 
  end

  def approve_detail
    inspection[:approve_detail].to_sym
  rescue
    nil    
  end

  def disapprove_detail
    inspection[:disapprove_detail].to_sym
  rescue
    nil    
  end

  def disapprove_comment
    _disapprove_comment = inspection[:disapprove_comment]
    if _disapprove_comment.present?
      _disapprove_comment[0...200]
    else
      nil
    end
  rescue
    nil
  end

  def completed_date_time
    Time.at(inspection[:completed_date_time])
  rescue
    nil    
  end

  def schedule
    inspection[:schedule]
  rescue
    nil  
  end

  def inspection_pdf_url
    if inspection[:ticket_url].present? and !inspection[:ticket_url].include?("missing.png")
      inspection[:ticket_url]
    else
      default_pdf
    end
  rescue
    nil    
  end

  def inspection_pdf_url_signed
    if inspection[:document_mission_url].present?      
      inspection[:document_mission_url]
    else
      default_pdf
    end
  rescue
    nil    
  end

  def disapprove_detail_text
    {
      :wrong_address        => 'Direccion erronea, calle indicada no es la correcta',
      :customer_not_appear  => 'Cliente no aparecio',
      :repeated             => 'Rechazada, Repetida',
      :out_of_coverage      => 'Sector fuera de cobertura',
      :dangerous_sector     => 'Sector peligroso',
      :not_found_customer   => 'Cliente no contactable',
      :customer_rejects     => 'Cliente no quiere seguro'
    }[disapprove_detail]
  end
  
  def company_patent
    inspection[:extension][:licence_plate]
  rescue
    self.patent
  end

  def admin_user_id
    inspection[:admin_user_id]      
  rescue
    nil     
  end

  def inspection
    @inspection ||= JSON.parse(
      ::HTTParty.get(
        "#{ENV['COMPANY_URL']|| 'http://localhost:3000'}/api/missions/#{self.mission_id}", 
        { 
          headers: ::Iclient::Constants::company_auth_headers
        }
      ).body, 
      symbolize_names: true
    )
  rescue => e
    puts "Error de búsqueda: #{e.message} / mission_id: #{self.mission_id}"
    {}       
  end 
  
  def default_pdf
    "https://doc-extras.s3.amazonaws.com/default.pdf"
  end
  
end