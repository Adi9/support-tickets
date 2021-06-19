Rails.application.routes.draw do
  resources :support_tickets, only: [:index, :create, :new]

  root 'support_tickets#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
