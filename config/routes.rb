Rails.application.routes.draw do
  get 'home/index'
  devise_for :users
  root to: "home#index"

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
