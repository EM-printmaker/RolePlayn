Rails.application.routes.draw do
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

  # city
  resources :cities, only: [ :index, :show ] do
    collection do
      post :shuffle
      post :re_roll
    end
    member do
      get :load_more
    end
  end

  # expression
  resources :expressions, only: [] do
    collection do
      post :change_face
      post :preview
    end
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
