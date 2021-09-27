class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products
  has_many :orders
  has_many :buylists, class_name: 'Order', foreign_key: 'buyer_id'
end
