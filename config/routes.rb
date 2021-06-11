Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope module: 'iclient/api/v1', path: 'iclient/api', constraints: Iclient::ApiVersion.new('v1', true) do
    resources :inspections, only: [:index, :create, :destroy]
    resources :insurance_brokers, only: [:index]
    resources :deductibles, only: [:index]
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq' 

end
