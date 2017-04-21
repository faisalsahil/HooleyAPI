Rails.application.routes.draw do

  devise_for :users

  resources :users, only:[] do
    collection do
      get 'activation'
    end
  end
  apipie
  # root to: 'apipie/apipies#index'
  root to: 'dashboards#index'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :users, only:[:index] do
        collection do
          get 'user_events'
          get 'user_posts'
          get 'user_followers'
          post 'block_user'
        end
      end
      resources :registrations, only: [] do
        collection do
          post :sign_up
          post :sing_up_social_media
          post :forgot_password
        end
      end
      resources :categories
      resources :member_profiles, only:[] do
        collection do
          get 'get_profile'
          get 'dropdown_data'
          get 'profile_timeline'
          post 'update_user_location'
        end
      end
      resources :posts, only:[:index, :destroy] do
        collection do
          get 'discover'
        end
        member do
          delete 'undo'
        end
        resources :post_likes, only:[:index]
        resources :post_comments, only:[:index, :destroy]
      end
      resources :member_followings, only:[] do
        collection do
          get 'get_followers'
          get 'get_following_requests'
        end
      end
      resources :events, only:[] do
        collection do
          get 'event_list_horizontal'
          get 'event_posts'
          get 'profile_events'
          get 'event_guests'
          post 'event_register'
          post 'event_attending_status'
          post 'event_add_members'
        end
      end
      resources :event_webs, only:[:index, :show, :destroy] do
        collection do
          post 'block_event'
        end
      end
      resources :user_sessions, only:[] do
        collection do
          post :login
        end
      end
      resources :dashboards, only:[:index]
      resources :event_bookmarks, only:[:index, :create]
    end
  end

  # root to: 'home#index'
  mount ActionCable.server => '/cable'
end