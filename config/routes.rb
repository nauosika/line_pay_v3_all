Rails.application.routes.draw do

  devise_for :users
  root to: "home#index"

  resources :products do
    collection  do
        get :own_products
        get :buylists
      end
    resources :orders do
      member  do
        post :linerequest
        post :linerefund
      end
    end
  end

  get :confirm, to: "confirm#check"
end
