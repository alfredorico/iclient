class AddGamaToBrands < ActiveRecord::Migration[6.0]
  def change
    add_column :iclient_vehicle_brands, :gama, :string
  end
end
