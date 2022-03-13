Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'reports#index'
  get 'oauth2callback' => 'reports#index'
  get 'download_report' , to: 'reports#download_report' , as: :download_report
  get 'connect_google_sheets' , to: 'reports#connect_google_sheets' , as: :connect_google_sheets
  
end
