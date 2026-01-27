Rails.application.routes.draw do
  get "observations/show"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # root
  root "top#index"

  # top
  get "top/load_more", to: "top#load_more", as: :load_more_top

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
    end
  end

  # operations
  scope module: :operations do
    resources :shuffles,   only: [ :create ]
    resources :re_rolls,   only: [ :create ]
    resources :expressions, only: [ :create ]
  end

  # セキュリティのためこれより下に通常のルーティング設定を追加しないこと

  get "/:slug",
      to: "worlds#show",
      as: :world,
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

  direct :city do |city|
    world_city_path(city.world, city)
  end

  direct :load_more_city do |city|
    load_more_world_city_path(city.world, city)
  end

  direct :observation do |character|
    target_world = character.city.world
    observer_city = City.observer_for(target_world) || target_world.observation_city
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
