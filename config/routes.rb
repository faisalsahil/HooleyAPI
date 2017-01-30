Rails.application.routes.draw do

  devise_for :users

  apipie
  root to: 'apipie/apipies#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :registrations, only: [] do
        collection do
          post :sign_up
          post :sing_up_social_media
          post :forgot_password
        end
      end
      resources :member_profiles, only:[] do
        collection do
          get 'get_profile'
          get 'dropdown_data'
          get 'profile_timeline'
        end
      end
      
      resources :member_followings, only:[] do
        collection do
          get 'get_followers'
        end
      end

      resources :events, only:[:index] do
        collection do
          get 'event_list_horizontal'
        end
      end
      
      resources :user_sessions, only:[] do
        collection do
          post :login
        end
      end
    end
  end

  # root to: 'home#index'
  mount ActionCable.server => '/cable'
end