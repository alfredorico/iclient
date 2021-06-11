module Iclient
  module ServiceCredentials
    extend ActiveSupport::Concern

    def id_ingreso_usuario
      case self.campain_id
      when 1449,1991,1992
        ENV['ID_INGRESO_USUARIO']        
      when 1450
        ENV['COMPARA_ID_INGRESO_USUARIO']
      else
        'AUX20190000000801'
      end      
    end

    def rut_usuario
      case self.campain_id
      when 1449,1991,1992
        ENV['RUT_USUARIO']        
      when 1450
        ENV['COMPARA_RUT_USUARIO']
      else
        '77078150'
      end      
    end

    def id_usuario
      case self.campain_id
      when 1449,1991,1992
        ENV['ID_USUARIO']        
      when 1450
        ENV['COMPARA_ID_USUARIO']
      else
        '32'
      end      
    end

    def id_inspector
      case self.campain_id
      when 1449,1991,1992
        ENV['ID_INSPECTOR']        
      when 1450
        ENV['COMPARA_ID_INSPECTOR']
      else
        '237'
      end      
    end    
    
  end
end