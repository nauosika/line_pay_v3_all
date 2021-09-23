class Order < ApplicationRecord
  belongs_to :product
  validates :quantity, presence: true, numericality: { only_integer: true }
  before_save :body

  private
  def total_amount
    self.amount = self.quantity * self.product.price
  end

  def body
    self.total_amount()
    self.order_id = "order#{SecureRandom.uuid}"
    self.packages_id = "pack#{SecureRandom.uuid}"
    self.name = self.product.name
    self.price = self.product.price
  end
end
