class Iclient::Inspection < ApplicationRecord
  belongs_to :inspection_type
  belongs_to :vehicle_brand
  belongs_to :vehicle_model
  belongs_to :vehicle_type
  has_many :damages, dependent: :destroy
  has_many :attachments, dependent: :destroy # not used
  has_many :vehicle_accessories, dependent: :destroy
  has_many :vehicle_check_lists, dependent: :destroy
  include Iclient::ServiceCredentials
  include Iclient::WorkflowSteps
  include Iclient::IclientVehicleValidation
  include Iclient::CompanyInspection
  include Iclient::DataUpdater
  include Iclient::VehicleFeatures  
  include Iclient::InspectionCloningManagement 
  include Iclient::IclientStates 
  include Iclient::InspectionDbCallbacks 
  include Iclient::Resolution 
  include Iclient::ChecklistAlerts 
end
