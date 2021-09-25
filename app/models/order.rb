class Order < ApplicationRecord
  include Linepay

  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true }

  after_create :set_order


  #state
  include AASM

  aasm column: :state do
    state :pending, initial: true
    state :confirmed

    event :check do
      transitions from: :pending, to: :confirmed
    end
  end

  private
  def set_order
    order_id = "order#{SecureRandom.uuid}"
    packages_id = "pack#{SecureRandom.uuid}"
    self.amount = self.quantity * self.product.price
    self.order_id = order_id
    self.packages_id = packages_id
    self.name = self.product.name
    self.price = self.product.price
  end
end
