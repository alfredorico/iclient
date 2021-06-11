module Iclient
  module HttpBasicAuth
    
    extend ActiveSupport::Concern
    included do
      include(ActionController::HttpAuthentication::Basic::ControllerMethods)      
    end
    def http_authenticate!
      authenticate_or_request_with_http_basic do |key, secret|
        (key == ENV['USER_BASIC'] and secret == ENV["PASSWORD_BASIC"])
      end
    end
    
  end
end

=begin
=end