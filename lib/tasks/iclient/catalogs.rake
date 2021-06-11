namespace :iclient do
  namespace :catalogs do
    desc "inspection_types load"
    task load_inspection_types: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::InspectionType.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/tipoinspecciones"
                        ).body, 
                        symbolize_names: true
                )        
        data.each do |datum|
          Iclient::InspectionType.create(
            id: datum[:IdTipoInspeccion], description: datum[:Descripcion].squish
          )
        end        
      end
    end

    desc "vehicle_brands load"
    task load_vehicle_brands: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::VehicleBrand.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/marcas"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::VehicleBrand.create(
            id: datum[:CodigoMarca].squish, description: datum[:NombreMarca].squish
          )
        end        
      end
    end

    desc "vehicle_models load"
    task load_vehicle_models: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::VehicleModel.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/modelos"
                        ).body, 
                        symbolize_names: true
                )
        
        # Handling poor data from Iclient ---------
        data.delete_if {|h| h[:CodigoModelo] == "WRISTREE"}
        data << {
          CodigoMarca: "WRI",
          CodigoModelo: "WRISTREE",
          DescripcionModelo: "STREETDECK"
        }
        # ------------------------------------------
        data.each do |datum|
          brand_description = Iclient::VehicleBrand.find_by(id: datum[:CodigoMarca])&.description || datum[:CodigoMarca].squish
          Iclient::VehicleModel.create(
            vehicle_brand_id: datum[:CodigoMarca].squish, 
            brand_description: brand_description,
            id: datum[:CodigoModelo].squish, 
            description: datum[:DescripcionModelo].squish
          )
        end        
      end
    end

    desc "cities load"
    task load_cities: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::City.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/ciudades"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::City.create(
            id: datum[:CodigoCiudad].squish, 
            description: datum[:NombreCiudad].squish
          )
        end        
      end
    end

    desc "communes load"
    task load_communes: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::Commune.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/comunas"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::Commune.create(
            city_id: datum[:CodigoCiudad].squish, 
            id: datum[:CodigoComuna].squish, 
            description: datum[:DescripcionComuna].squish
          )
        end
        ActiveRecord::Base.connection.execute <<-SQL
          update iclient_communes set description = 'CABO DE HORNOS (EX. NAVARINO)' where description = 'CABO DE HORNOS';
          update iclient_communes set description = 'CANELA' where description = 'CANELA BAJA';
          update iclient_communes set description = 'GENERAL LAGOS' where description = 'ENTRE LAGOS';
          update iclient_communes set description = 'LA CALERA' where description = 'CALERA';
          update iclient_communes set description = 'LAJA' where description = 'LA LAJA';
          update iclient_communes set description = 'MARCHIGUE' where description = 'MARCHIHUE';
          update iclient_communes set description = 'MOSTAZAL' where description = 'SAN FRANCISCO DE MOSTAZAL';
          update iclient_communes set description = 'O''HIGGINS' where description = 'O`HIGGINS';
          update iclient_communes set description = 'OLIVAR' where description = 'OLIVAR ALTO';
          update iclient_communes set description = 'SAN FABIAN' where description = 'SAN FABIAN DE ALICO';
          update iclient_communes set description = 'VICHUQUEN' where description = 'LAGO VICHUQUEN';  
          update iclient_communes set description = 'AYSEN' where description = 'AISEN';
        SQL
      end
    end    

    desc "vehicle_targets load"
    task load_vehicle_targets: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::VehicleTarget.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/usosvehiculos"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::VehicleTarget.create(
            id: datum[:IdUsoVehiculo].squish, 
            description: datum[:Descripcion].squish
          )
        end        
      end
    end    

    desc "accesories load"
    task load_accesories: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::Accessory.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/accesorios"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::Accessory.create(
            id: datum[:IdAccesorio], 
            description: datum[:Nombre].squish
          )
        end        
      end
    end 

    desc "accessory features load"
    task load_accessory_features: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::AccessoryFeature.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/caracteristicasAccesorio"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::AccessoryFeature.create(
            accesory_id: datum[:IdAccesorio],
            id: datum[:IdCaracteristica], 
            description: datum[:NombreCaracteristica].squish
          )
        end        
      end
    end 

    desc "vechile parts load"
    task load_vehicle_parts: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::VehiclePart.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/partesypiezas"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          exclude_deductible = case datum[:IdPartePieza]
          when 19,16,14,15 # VIDRIOS
            true
          else
            false
          end
          Iclient::VehiclePart.create(
            id: datum[:IdPartePieza], 
            description: datum[:NombrePartePieza].squish,
            agrupation: datum[:Agrupacion],
            exclude_deductible: exclude_deductible
          )
        end        
      end
    end     

    desc "perspective load"
    task load_perspectives: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::Perspective.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/perspectivas"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::Perspective.create(
            id: datum[:IdPerspectiva], 
            description: datum[:NombrePerspectiva].squish,
          )
        end        
      end
    end    

    desc "damage types load"
    task load_damage_types: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::DamageType.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/tiposdanos"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::DamageType.create(
            id: datum[:CodigoTipoDano], 
            description: datum[:NombreTipoDano].squish,
          )
        end        
      end
    end    

    desc "check lists load"
    task load_check_lists: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::CheckList.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/checklist"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::CheckList.create(
            id: datum[:IdChecklist], 
            description: datum[:Descripcion].squish,
          )
        end        
      end
    end    

    desc "vehicle types load"
    task load_vehicle_types: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::VehicleType.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/tiposvehiculos"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|

          weight = case datum[:IdTipoVehiculo]
          when '5','6','9','11','12','13','15','16','21','30','40','57','58','59','60','61','62','64'
            'H' # HEAVYWEIGHT
          else
            'L' # LIGHTWEIGHT
          end

          Iclient::VehicleType.create(
            id: datum[:IdTipoVehiculo], 
            description: I18n.transliterate(datum[:Descripcion].squish),
            weight: weight
          )
        end        
      end
    end    

    desc "vehicle transmission type load"
    task load_vehicle_transmission_types: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::VehicleTransmissionType.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/tipotransmision"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::VehicleTransmissionType.create(
            id: datum[:IdTipoTransmision], 
            description: datum[:NombreTipoTransmision].squish
          )
        end        
      end
    end    
    
    desc "vehicle transmission type load"
    task load_inspection_origins: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::InspectionOrigin.delete_all
        # data =  JSON.parse(
        #                 ::HTTParty.get(
        #                   "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/tipoorigen"
        #                 ).body, 
        #                 symbolize_names: true
        #         ) 
        data = [
          {id: 1, description: 'Punto Proveedor'},
          {id: 2, description: 'Domicilio'},
          {id: 3, description: 'Autoinspección Falabella'},
          {id: 4, description: 'Express'},
          {id: 5, description: 'Dealer'},
        ]
        
        data.each do |datum|
          Iclient::InspectionOrigin.create(
            id: datum[:id], 
            description: datum[:description].squish
          )
        end        
      end
    end  

    desc "insurance brokers load"
    task load_insurance_brokers: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::InsuranceBroker.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/corredores"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::InsuranceBroker.create(
            id: datum[:IdCorredor], 
            rut: datum[:RutCorredor], 
            name: datum[:NombreCorredor].squish
          )
        end        
      end
    end   

    desc "inspection states load"
    task load_inspection_states: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::InspectionState.delete_all
        data =  JSON.parse(
                        ::HTTParty.get(
                          "https://www.iclient.com/Corporate/Web/Proveedor/api/parametros/estados"
                        ).body, 
                        symbolize_names: true
                ) 
        data.each do |datum|
          Iclient::InspectionState.create(
            id: datum[:IdEstado], 
            description: datum[:Nombre]
          )
        end        
      end
    end

    desc "damages severities load"
    task load_damage_severities: :environment  do
      ActiveRecord::Base.transaction do
        Iclient::DamageSeverity.delete_all
        Iclient::DamageSeverity.create([
          {id: 'L', description:	'Leve'},
          {id: 'M', description:	'Mediano'},
          {id: 'G', description:	'Grave'},
          {id: 'E', description:	'Excluido'},
        ])    
      end
    end

    desc "setting gama to brands"
    task setting_gama_to_brands: :environment  do
      sql = <<-SQL
        begin;
          update iclient_vehicle_brands set gama = 'L' where id in ('BAI', 'BRI', 'BYD', 'CGN', 'CHG', 'CRY', 'DAE', 'DAI', 'DAT', 'DFM', 'DFS', 'FAW', 'FIA', 'FOT', 'GAC', 'GEE', 'GMC', 'GWM', 'HAF', 'HAI', 'HAV', 'IVE', 'JAC', 'JMC', 'KEB', 'LAD', 'LIF', 'LWI', 'MAH', 'MG_', 'NIS', 'PRO', 'SAM', 'SEA', 'TAT', 'ZNA', 'ZOY', 'ZX_');
          update iclient_vehicle_brands set gama = 'M' where id in ('CHE','CHR','CIT','DOD','FOR','HON','HYU','JEE','KIA','LAN','MAZ','MIT','OPE','PEU','REN','SKO','SSA','SUB','SUZ','TOY','VWG');
          update iclient_vehicle_brands set gama = 'H' where id in ('ACU''ALF','ASM','AUD','BMW','FRR','HUM','INF','JAG','LRO','LEX','MAS','MCL','MER','MIN','MOR','POR','SAA','SRT','VOL');
        commit;
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

  end
end

=begin
heroku run rake iclient:catalogs:load_inspection_types
heroku run rake iclient:catalogs:load_vehicle_brands
heroku run rake iclient:catalogs:load_vehicle_models
heroku run rake iclient:catalogs:load_cities
heroku run rake iclient:catalogs:load_communes
heroku run rake iclient:catalogs:load_vehicle_targets
heroku run rake iclient:catalogs:load_accesories
heroku run rake iclient:catalogs:load_accessory_features
heroku run rake iclient:catalogs:load_vehicle_parts
heroku run rake iclient:catalogs:load_perspectives
heroku run rake iclient:catalogs:load_damage_types
heroku run rake iclient:catalogs:load_check_lists
heroku run rake iclient:catalogs:load_vehicle_types
heroku run rake iclient:catalogs:load_vehicle_transmission_types
heroku run rake iclient:catalogs:load_inspection_origins
heroku run rake iclient:catalogs:load_insurance_brokers
heroku run rake iclient:catalogs:load_inspection_states
heroku run rake iclient:catalogs:load_damage_severities
=end