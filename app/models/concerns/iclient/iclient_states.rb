module Iclient
  module IclientStates

    def iclient_state_description
      iclient_state_definitions[self.iclient_state]
    end

    def iclient_state_definitions
      {
        'F' => 'FALLA DE SERVICIO ICLIENT',
        '0' => 'NO INGRESADA EN ICLIENT',
        '1' => 'APROBADO',
        '13' => 'APROBADO',
        '14' => 'REPROBADO',
        '2' => 'REPROBADO',
        '3' => 'PENDIENTE POR SUSCRIPCION',
        '4' => 'FALLIDA',
        '5' => 'EN PROCESO INSPECTOR'
      }
    end

    def iclient_state_rockeptin_matching
      {
        '1' => 'approved',
        '2' => 'rejected',
        '3' => 'pending',
        '4' => 'failed',
        '13' => 'approved',
        '14' => 'rejected',
        '5' => 'waiting_review'
      }[self.iclient_state]
    end

  end
end
