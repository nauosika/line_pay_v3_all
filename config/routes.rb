Rails.application.routes.draw do
  devise_for :users
  root "products#index"

  resources :products do
    resources :orders do
      member  do
        post 'linerequest'
        post 'linerefund'
      end
    end
  end

  get "confirm", to: "confirm#check"
end
