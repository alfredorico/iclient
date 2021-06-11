module Iclient
  module Constants

    def self.company_auth_headers
      email = 'integradorapi@user.com'
      response = RestClient.post(
        "#{ENV['COMPANY_URL']|| 'http://localhost:3000'}/api/sessions",
        {
          email: email,
          password: ENV["COMPANY_PASS"]
        }.to_json,
        {
          'Content-Type' => 'application/json',
        }
      )
      
      return {  
        'Content-Type' => 'application/json',
        'Accept' => 'application/vnd.company+json; version=2',
        'X-AdminUser-Email' => email,
        'X-AdminUser-Token' => JSON.parse(response.body)["authentication_token"]
      }

      # return {  
      #   'Content-Type' => 'application/json',
      #   'Accept' => 'application/vnd.company+json; version=2',
      #   'X-AdminUser-Email' => email,
      #   'X-AdminUser-Token' => 'pcBsP3R9xpR1RWQrRfxZ'
      # }

      
    end
  end
end
