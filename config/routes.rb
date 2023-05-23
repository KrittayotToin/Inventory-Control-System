Rails.application.routes.draw do
 # config/routes.rb

 devise_for :users, controllers: {
  omniauth_callbacks: 'omniauth_callbacks',
  sessions: 'users/sessions',
  registrations: 'users/registrations',
  passwords: 'users/passwords'
}
#  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
#  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }



  root 'home#index'
  get 'dashboard/index'

  #excel upload
  post '/process_excel', to: 'equipment#process_excel' 
  get '/equipments/excel' ,to: 'equipment#excel', as: 'equipment_excel'
  # get 'log_control/index'
  # get 'log_control/new'
  # get 'log_control/create'
  # get 'log_control/edit'
  # get 'log_control/update'
  # get 'log_control/destroy'
  
  
  get '/logs', to: 'log_control#index', as: 'log_control_index'
  post '/logs', to: 'log_control#create', as: 'log_control_create'
  get '/logs/new', to: 'log_control#new', as: 'new_log_control'
  patch 'logs/:id/return', to: 'log_control#return_equipment', as: 'return_equipment'

  # member router
  get '/member', to: 'member#index', as: 'member_index'
  get '/members/all', to: 'member#all', as: 'member_all'
  get '/member/new', to: 'member#new', as: 'new_member'
  get '/member/:id', to: 'member#show', as: 'show_member'
  get '/member/:id/edit', to: 'member#edit', as: 'edit_member'
  post '/member', to: 'member#create'
  put '/member/:id', to: 'member#update', as: 'update_member'
  delete '/member/:id', to: 'member#destroy', as: 'delete_member'

  # equipment router
  get '/equipment', to: 'equipment#index', as: 'equipment_index'
  get '/equipment/new', to: 'equipment#new', as: 'new_equipment'
  get '/equipment/:id', to: 'equipment#show', as: 'show_equipment'
  get '/equipment/:id/edit', to: 'equipment#edit', as: 'edit_equipment'
  post '/equipment', to: 'equipment#create'
  put '/equipment/:id', to: 'equipment#update', as: 'update_equipment'
  delete '/equipment/:id', to: 'equipment#destroy', as: 'delete_equipment'


  get '/equipment_names', to: 'equipment#equipment_names'
  get '/member_names', to: 'member#member_names'





  # resources :equipment
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
