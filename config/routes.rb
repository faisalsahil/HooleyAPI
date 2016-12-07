Rails.application.routes.draw do

  devise_for :users

  apipie
  root to: 'apipie/apipies#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      get 'admin_dashboards/index'
      resources :admin_profiles, only: [:edit, :update]
      resources :admin_dashboards, only: [:index]
      resources :registrations, only: [] do
        collection do
          post :sign_up
          post :sing_up_social_media
          post :forgot_password
        end
      end
      resources :events do
        collection do
          post 'event_match'
        end
      end
      resources :messages do
        collection do
          get 'show_inbox'
          get 'sent_messages'
        end
      end
      resources :member_profiles do
        collection do
          get 'user_list'
          post 'find_athlete'
          post 'find_coach'
          get 'profile_timeline'
        end
        member do
          get :post_list
        end
      end
      resources :fans do
        collection do
          get 'fan_requests'
          get 'accept_fan_request'
          get 'reject_fan_request'
        end
      end
      resources :countries, only: [:index] do
        collection do
          get 'city_list'
          get 'state_list'
          get 'currency_list'
        end
      end
      resources :roles, only: [:index]
      resources :user_sessions do
        collection do
          post :login
        end
      end
      resources :banners
      resources :sports do
        collection do
          get 'sport_position_list'
        end
      end
      resources :sport_positions
      resources :messages
      resources :sport_abbreviations
      resources :user_albums do
        collection do
          get 'show_album'
          get 'add_image_to_album'
        end
      end
      resources :users do
        collection do
          get :get_users_list
        end
      end
      resources :member_groups, only: [] do
        collection do
          get :user_groups
        end
        member do
          get    :group_details
          delete :group_destroy
        end
      end
      resources :posts, only: [:index, :show] do
        member do
          get :post_comments
          get :post_likes
          delete :destroy_post
          delete :destroy_post_comments
        end
        collection do
          post   :create_post
          get    :get_user_posts
        end
      end
      resources :post_comments, only:[:create]
      resources :report_posts, only: [:index, :show] do
        member do
          delete :destroy
          delete :remove_post_from_report
        end
      end
      resources :report_comments, only: [:index, :show] do
        member do
          delete :destroy
          delete :remove_comment_from_report
        end
      end
    end
  end

  # root to: 'home#index'
  mount ActionCable.server => '/cable'
end