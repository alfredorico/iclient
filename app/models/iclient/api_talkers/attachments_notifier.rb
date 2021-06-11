module Iclient
  module ApiTalkers
    class AttachmentsNotifier < Inspection

      include ::Iclient::NotifyLogger 

      def data
        @data ||= AttachmentsResponseBuilder.find(self.id).data
      end
  
      def notify
        unless @response
          @response = ::HTTParty.send(http_method, url, { 
            headers: {
              'Content-Type' => 'application/json',
            },
            body: data,
            verify: false
          })
  
          # For mocking: -------------------------------------------------
          # @response = OpenStruct.new
          # @response.code = 200
          # # For first time transmition
          # @response.body = {Codigo: 200, IdInspeccion: 999}.to_json        
          # sleep(5)
          # End mocking ----------------------------------------------------
  
          parsing_response
        end
        @response
      rescue => e
        puts "EXCEPTION mission_id: #{self.mission_id} MENSAJE: #{e.message} #{e.backtrace[0..10].to_s}"

        if e.message&.strip&.downcase == "connection reset by peer" 
          update( 
            sent_iclient_at: Time.now, 
            successfully_notify: false,
            unexpected_exception: true, 
            unexpected_exception_message: e.message,
            http_status: nil,
            http_response_body: nil,
            need_reduce_size_photos: true
          )          
        else
          update( 
            sent_iclient_at: Time.now, 
            successfully_notify: false,
            unexpected_exception: true, 
            unexpected_exception_message: e.message,
            http_status: nil,
            http_response_body: nil
          )          
        end
        @response
      end
      
      def http_method
        :post
      end
  
      def url
        ENV['ICLIENT_ATTACHMENTS_URL'] || 'https://www.iclient.com/Corporate/Web/Proveedor/api/inspeccion/fotodocumento'
      end
  
      private
      def parsing_response
        api_body_response = JSON.parse(@response.body, symbolize_names: true)
        
        # Watch data and response
        notify_log(show_data: false)
        # ----------------------------

        if @response.code == 200
          if api_body_response[:Exito] == true 
            update(
              sent_iclient_at: Time.now, 
              successfully_notify: true,
              response_message: nil,
              response_message_extra: nil,
              http_status: 200,
              http_response_body: nil,
              need_reduce_size_photos: false
            ) 
          else
            update(
              sent_iclient_at: Time.now, 
              successfully_notify: false,
              response_message: api_body_response[:Mensaje],
              response_message_extra: api_body_response[:MensajeExtra],
              need_reduce_size_photos: false
            )          
          end
        else
          update(
            sent_iclient_at: Time.now,
            successfully_notify: false,
            http_status: @response.code,
            http_response_body: @response.body,
            need_reduce_size_photos: false          
          )
        end

      end    
    end
  end
end