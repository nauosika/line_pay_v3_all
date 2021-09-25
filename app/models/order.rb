class Order < ApplicationRecord
  include Linepay

  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true }

  after_create :set_order


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

  def set_confirm_data(transactionId, regKey)
    self.transactionid = transactionId
    self.regkey = regKey
    self.check
    self.save
  end

  def set_refund_data(refundTransactionId, refundTransactionDate)
    self.refund_id = refundTransactionId.to_s
    self.refund_date = refundTransactionDate
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
