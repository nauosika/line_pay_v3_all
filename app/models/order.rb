class Order < ApplicationRecord
  include Linepay

  belongs_to :product
  belongs_to :user

  validates :quantity, presence: true, numericality: { only_integer: true }

  after_create :set_order

  scope :created_desc, -> {order(id: :desc)}

  #state
  include AASM

  aasm column: :state do
    state :pending, initial: true
    state :confirmed, :refunded

    event :check do
      transitions from: :pending, to: :confirmed
    end

    event :cancel do
      transitions from: :confirmed, to: :refunded
    end
  end

  def set_confirm_data(response, current_user_id)
    self.transactionid = response["info"]["transactionId"]
    self.regkey = response["info"]["regKey"]
    self.buyer_id = current_user_id
    self.check
    self.save
  end

  def set_refund_data(response)
    self.refund_id = response["info"]["refundTransactionId"]
    self.refund_date = response["info"]["refundTransactionDate"]
    self.cancel
    self.save
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
