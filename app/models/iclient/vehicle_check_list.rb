class Iclient::VehicleCheckList < ApplicationRecord
  belongs_to :inspection
  belongs_to :check_list
end
