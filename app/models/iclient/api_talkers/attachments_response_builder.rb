module Iclient
  module ApiTalkers
    class AttachmentsResponseBuilder < Inspection
  

      def responses_translater
        @responses_translater ||= ResponsesTranslater.new(mission_id: self.mission_id) 
      end

      def photos_key
        unless @photos_key
          
          @photos_key =  [
            "foto frontal del padrón",
            "foto posterior del padrón",
            "frontal derecho (lado del copiloto)",
            "frontal izquierdo (lado del conductor)",
            "posterior derecho (lado del copiloto)",
            "posterior izquierdo (lado del conductor)",
            "foto de n° chasis o vin",
            "motor",
            "panel interno encendido con kilometraje",
            "rueda de repuesto",
            "radio del vehículo encendida",
            "Constancia Cliente", # Caso especial en el que no es el nombre de la pregunta del form!!
            "airbag",
            "chapa del lado del copiloto (lado derecho)",
            "lateral derecho (lado del copiloto)",
            ] | responses_translater.responses_by_id.keys.grep(/foto de daño/) | responses_translater.responses_by_id.keys.grep(/fotos de daños/) | responses_translater.responses_by_id.keys.grep(/fotografía de estado de los neumáticos delanteros/) | responses_translater.responses_by_id.keys.grep(/fotografía de estado de los neumáticos traseros/)
          # TODO: Reemplazar foto de chapa por una de daño si existen daños.
          # @photos_key = @photos_key.take(15) 
        end
        @photos_key
      end

      def convert_base64(url:)
        require 'open-uri'
        begin
          if url
            if self.need_reduce_size_photos
              image = MiniMagick::Image.open(url)
              image.size
              image.resize ENV['PHOTOS_RESIZE_PERCENT']
              Base64.strict_encode64(image.to_blob)            
            else
              img = open(url)
              Base64.strict_encode64(img.read)
            end
          end
        rescue => e
          puts "Base64 Excepción url #{url} en método convert_base64 missión #{self.mission_id}: #{e.message}"
        end
      end

      def convert_document_base64(url:)
        require 'open-uri'
        begin
          if url
            img = open(url)
            Base64.strict_encode64(img.read)
          end
        rescue => e

          puts "Base64 Excepción url #{url} en missión #{self.mission_id}: #{e.message}"
        end
      end

      def data
        <<-JSON
          {
            "Permiso": {
              "IdIngresoUsuario": "#{id_ingreso_usuario}",
              "RutUsuario": #{rut_usuario},
              "IdUsuario": #{id_usuario},
              "Ip": "",
              "Origen": 1
            },
            "IdInspeccion": #{self.id_inspection}
            #{attachments_data}
          }
        JSON
      end

      def base64_inspection_signature
        unless @inspection_signature
          pdf = MiniMagick::Image.open(inspection_pdf_url_signed)
          png = MiniMagick::Tool::Convert.new do |convert|
            convert.background "white"
            convert.flatten
            convert.quality 100 
            convert << pdf.pages.first.path
            convert << "png:-"
          end
          @inspection_signature = Base64.strict_encode64(png)                  
        end
        @inspection_signature
      rescue => e
        msg = ":warning: <@U6NBF7DKN> Inspección #{self.mission_id} no pudo efecutar conversión de PDF a JPG para tranmisión de firma. ERROR: #{e.message}"
        puts msg
        SlackNotifier::CompanyTI.ping(msg)
        nil
      end
      
      def attachments_data
        unless @attachments_data
          @attachments_data = <<-JSON        
            ,"Fotos": [
          JSON
          photos_array = []
          photos_key.each_with_index do |key, i|
            
            if i == 11 # ID 12 (posicion 11 del vector) se envía 'Informe Inspección o Comprobante Firma Cliente'
              photo_url = ""
              base64 = base64_inspection_signature
            else
              photo_url = responses_translater.responses_by_id[key]
              base64 = convert_base64(url: photo_url)
            end
            puts "Foto #{i+1}: converting '#{key}' #{photo_url}"
            
            if base64
              _index = if (i + 1) >= 13
                if key&.downcase&.include?('daño')
                  14
                elsif ( key&.downcase&.include?('fotografía de estado de los neumáticos delanteros') and responses_translater.front_tire_worn? )
                  key = 'neumaticos delanteros'
                  14
                elsif   ( key&.downcase&.include?('fotografía de estado de los neumáticos traseros') and responses_translater.rear_tire_worn? )
                  key = 'neumaticos traseros'
                  14
                else
                  13
                end
              else
                (i + 1)
              end               
              photos_array << <<-JSON        
                {
                  "IdFoto": #{_index},
                  "Foto": "#{base64}",
                  "Nombre": "#{key[0...20]}"
                }
              JSON
            end
          end
          @attachments_data << photos_array.join(",")
          @attachments_data << "]"
          
          # Documents
          @attachments_data << <<-JSON        
            ,"Documento": [
                {
                  "IdDocumento": 16,
                  "Documento": "#{convert_document_base64(url: inspection_pdf_url)}",
                  "Nombre": "Documento #{self.id_inspection}"
                }
              ]            
          JSON
        end
        @attachments_data
      end

      
    end
  end
end