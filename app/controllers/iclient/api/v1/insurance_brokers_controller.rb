module Iclient
  module Api::V1
    class InsuranceBrokersController < ApplicationController
      def index
        render json: ::Iclient::InsuranceBroker.order(:name).map { |ib| {id: ib.id, rut_name: "#{ib.rut} / #{ib.name}"} } 
      end
    end
  end
  
end

=begin
curl -X GET \
-H "Accept:application/vnd.fid.v1+json" \
http://localhost:3001/iclient/api/insurance_brokers | jq . -C 
=end