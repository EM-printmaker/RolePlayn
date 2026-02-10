Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  authenticate :user, ->(user) { user.admin? || user.moderator? } do
    mount_avo at: "/avo"
  end
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # root
  root "top#index"

  # top
  get "top/load_more", to: "top#load_more", as: :load_more_top

  # devise
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  devise_scope :user do
    get "settings/password", to: "users/registrations#edit_password", as: :edit_password_settings
    patch "settings/password", to: "users/registrations#update_password", as: :update_password_settings
  end

  devise_scope :user do
    # 一般ゲストログイン用
    post "users/guest_sign_in", to: "users/sessions#new_guest"
    # モデレーターゲストログイン用
    post "users/guest_moderator_sign_in", to: "users/sessions#new_guest_moderator"
  end

  # users
  resource :profile, only: [ :show ], controller: "users" do
    get :load_more
    get "favorited-posts", to: "users#favorited_posts", as: :favorited_posts
  end

  # post
  resources :posts, only: [ :create, :destroy ]

  # world
  get "/worlds", to: "worlds#index", as: :worlds_index

  # city
  get "/cities", to: "cities#index", as: :cities_index

  # expression
  resources :expressions, only: [] do
    collection do
      post :preview
      get :favorites  # => /expressions/favorites
    end
  end

  # operations
  scope module: :operations do
    resources :shuffles,   only: [ :create ]
    resources :re_rolls,   only: [ :create ]
    resources :expressions, only: [ :create ]
    resources :character_selections, only: [ :create ]
  end

  # inquiries
  resources :inquiries, only: [ :new, :create ] do
    collection do
      post :confirm
      get :done
    end
  end

  # favorite
  scope module: :favorites do
    resources :expressions, only: [] do
      resource :favorite, only: [ :create, :destroy ], controller: :expressions
    end

    resources :posts, only: [] do
      resource :favorite, only: [ :create, :destroy ], controller: :posts
    end
  end

  # notifications
  post "notifications/read", to: "notifications#read", as: :read_notifications

  # login_modal
  get "login_announcement", to: "pages#login_announcement"

  # セキュリティのためこれより下に通常のルーティング設定を追加しないこと

  get "/:slug",
      to: "worlds#show",
      as: :world_show,
      constraints: { slug: /[a-z0-9\-]+/ }

  get "/:world_slug/:slug",
      to: "cities#show",
      as: :world_city,
      constraints: { world_slug: /[a-z0-9\-]+/, slug: /[a-z0-9\-]+/ }

  get "/:world_slug/:slug/load_more",
      to: "cities#load_more",
      as: :load_more_world_city,
      constraints: { world_slug: /[a-z0-9\-]+/, slug: /[a-z0-9\-]+/ }

  get "/:world_slug/:city_slug/observations/:subject_id",
    to: "observations#show",
    as: :world_city_observation,
    constraints: { world_slug: /[a-z0-9\-]+/, city_slug: /[a-z0-9\-]+/ }

  get "/:world_slug/:city_slug/observations/:subject_id/load_more",
    to: "observations#load_more",
    as: :load_more_world_city_observation,
    constraints: { world_slug: /[a-z0-9\-]+/, city_slug: /[a-z0-9\-]+/ }

  direct :world do |world|
    world_show_path(slug: world.slug)
  end

  direct :city do |city|
    world_city_path(world_slug: city.world.slug, slug: city.slug)
  end

  direct :load_more_city do |city|
    load_more_world_city_path(world_slug: city.world.slug, slug: city.slug)
  end

  direct :observation do |character|
    observer_city = character.primary_observer || character.city
    world_city_observation_path(
      world_slug: observer_city.world.slug,
      city_slug: observer_city.slug,
      subject_id: character.id
    )
  end

  direct :load_more_observation do |city, character|
    load_more_world_city_observation_path(
      world_slug: city.world.slug,
      city_slug: city.slug,
      subject_id: character.id
    )
  end


  # CDNを用いた画像表示用のURL作成
  direct :cdn_image do |model, options|
    next nil if model.nil? || (model.respond_to?(:attached?) && !model.attached?)

    if model.respond_to?(:key)
      key = model.key
    elsif model.respond_to?(:variation)
      variant = model.blob.variant_records.find { |vr| vr.variation_digest == model.variation.digest }
      key = variant&.key || model.blob.key
    else
      key = model.respond_to?(:blob) ? model.blob.key : nil
    end

    cdn_host = ENV.fetch("CDN_HOST", nil)
    if key.present? && cdn_host.present?
      "https://#{cdn_host}/#{key}"
    else
      route_for(:rails_blob, model, options)
    end
  end
end
