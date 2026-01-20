Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "top#index"

  direct :cdn_image do |model, options|
    target = model.respond_to?(:processed) ? model.processed : model
    key = target.respond_to?(:key) ? target.key : (target.respond_to?(:blob) ? target.blob.key : nil)

    if key.present? && ENV["CDN_HOST"].present?
      "https://#{ENV["CDN_HOST"]}/#{key}"
    else
      route_for(:rails_blob, model, options)
    end
  end
end
