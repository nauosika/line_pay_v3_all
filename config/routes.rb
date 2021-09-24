Rails.application.routes.draw do
  root "products#index"

  resources :products do
    resources :orders do
      member  do
        post 'linerequest'
      end
    end
  end

  get "confirm" , to: "confirm#check"
end
