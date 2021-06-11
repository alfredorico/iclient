class Iclient::Damage < ApplicationRecord
  belongs_to :inspection
  belongs_to :perspective
  belongs_to :vehicle_part
  belongs_to :damage_type
  belongs_to :damage_severity

  include Iclient::Deductible  

end
