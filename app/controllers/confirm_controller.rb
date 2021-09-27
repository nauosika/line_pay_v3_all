class ConfirmController < ApplicationController
  before_action :set_order_and_product, only: [:check]
  # before_action :authenticate_user!

  def check
    buyer_id = current_user.id
    transactionId = params[:transactionId]
    response = JSON.parse(@order.confirm_response(transactionId).body)
    if response["returnMessage"] == "Success."
      regKey = response["info"]["regKey"]
      @order.set_confirm_data(transactionId, regKey, buyer_id)
      NotifyMailer.buy_send_buyer(@order).deliver_now
      NotifyMailer.buy_send_owner(@order).deliver_now
      #sandbox 沒有regKey
      redirect_to  product_order_path(@product, @order)
    else
      redirect_to  product_path(@product)
    end
  end

  private
  def set_order_and_product
    begin
      @order = Order.find_by(order_id: params[:orderId])
      @product = Product.find_by(id: @order.product_id)
    rescue
      redirect_to products_path
    end
  end
end
