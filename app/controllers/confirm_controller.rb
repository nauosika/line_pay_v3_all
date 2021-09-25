class ConfirmController < ApplicationController
  before_action :set_order_and_product, only: [:check]

  def check
    transactionId = params[:transactionId]
    response = JSON.parse(@order.confirm_response(transactionId).body)
    if response["returnMessage"] == "Success."
      regKey = response["info"]["regKey"]
      @order.set_confirm_data(transactionId, regKey)
      #sandbox 沒有regKey
      redirect_to  product_order_path(@product, @order)
    else
      redirect_to  product_path(@product)
    end
  end

  private
  def set_order_and_product
    @order = Order.find_by(order_id: params[:orderId])
    @product = Product.find_by(id: @order.product_id)
  end
end
