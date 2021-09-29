class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :products
  has_many :orders
  has_many :buylists, class_name: 'Order', foreign_key: 'buyer_id'

  validates :name, presence: true
end
