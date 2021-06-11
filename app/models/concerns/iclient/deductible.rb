module Iclient
  module Deductible
    extend ActiveSupport::Concern

    included do
      DEDUCTIBLE_VALUES = {
        # Low Gama
        'L' => {
          # Damage Level
          'L' => 1, 'M' => 2, 'G' => 3 # Leve, Medio, Grave 
        },
        # Medium Gama
        'M' => {
          # Damage Level
          'L' => 2, 'M' => 4, 'G' => 6 # Leve, Medio, Grave 
        },
        # High Gamma
        'H' => {
          # Damage Level
          'L' => 4, 'M' => 6, 'G' => 8 # Leve, Medio, Grave 
        }
      }  
      before_save :calculate_deductible
    end


    def calculate_deductible
      if inspection.is_heavyweight_vehicle?
        if self.damage_severity_id != 'E'
          self.deductible = 8.0
        else
          self.deductible = 0
        end
      else
        if self.vehicle_part_id == 4 and self.perspective_id == 11 and damage_type_id == 1 and (inspection.vehicle_type_id == 3 or inspection.vehicle_type_id == 5)   # parte: parachoque, perspectiva: trasero, queda excluido de camioneta o camion
          self.damage_severity_id = 'E'
          self.deductible = 0
        elsif inspection.vehicle_brand.gama.present? and self.damage_severity_id != 'E'
          self.deductible = DEDUCTIBLE_VALUES[inspection.vehicle_brand.gama][self.damage_severity_id]
        else
          self.deductible = 0
        end
      end

    end

  end
end


=begin
MARCAS GAMA BAJA

 id  |  description  
-----+---------------
 BAI | BAIC
 BRI | BRILLIANCE
 BYD | BYD
 CGN | CHANGAN
 CHG | CHANGHE
 CRY | CHERY
 DAE | DAEWOO
 DAI | DAIHATSU
 DAT | DATSUN NISSAN
 DFM | DONGFENG
 DFS | DFSK
 FAW | FAW
 FIA | FIAT
 FOT | FOTON
 GAC | GAC GONOW
 GEE | GEELY
 GMC | GMC
 GWM | GREAT WALL
 HAF | HAFEI
 HAI | HAIMA
 HAV | HAVAL
 IVE | IVECO
 JAC | JAC
 JMC | JMC
 KEB | KENBO
 LAD | LADA
 LIF | LIFAN
 LWI | LANDWIND
 MAH | MAHINDRA
 MG_ | MG
 NIS | NISSAN
 PRO | PROTON
 SAM | SAMSUNG
 SEA | SEAT
 TAT | TATA
 ZNA | ZNA
 ZOY | ZOTYE
 ZX_ | ZX

MARCAS GAMA MEDIA
 id  | description 
-----+-------------
 CHE | CHEVROLET
 CHR | CHRYSLER
 CIT | CITROEN
 DOD | DODGE
 FOR | FORD
 HON | HONDA
 HYU | HYUNDAI
 JEE | JEEP
 KIA | KIA MOTORS
 LAN | LANCIA
 MAZ | MAZDA
 MIT | MITSUBISHI
 OPE | OPEL
 PEU | PEUGEOT
 REN | RENAULT
 SKO | SKODA
 SSA | SSANGYONG
 SUB | SUBARU
 SUZ | SUZUKI
 TOY | TOYOTA
 VWG | VOLKSWAGEN

MARCAS GAMA ALTA
  id  |  description  
-----+---------------
 ACU | ACURA
 ALF | ALFA ROMEO
 ASM | ASTON MARTIN
 AUD | AUDI
 BMW | BMW
 FRR | FERRARI
 HUM | HUMMER
 INF | INFINITI
 JAG | JAGUAR
 LRO | LAND ROVER
 LEX | LEXUS
 MAS | MASERATI
 MCL | MCLAREN
 MER | MERCEDES BENZ
 MIN | MINI
 MOR | MORGAN
 POR | PORSCHE
 SAA | SAAB
 SRT | SMART
 VOL | VOLVO


=end