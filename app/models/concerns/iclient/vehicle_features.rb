module Iclient
  module VehicleFeatures

    def is_heavyweight_vehicle?
      self.vehicle_type.weight == 'H'
    end

    def is_lightweight_vehicle?
      self.vehicle_type.weight == 'L'
    end

  end
end