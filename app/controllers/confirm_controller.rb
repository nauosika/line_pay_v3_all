class ConfirmController < ApplicationController
  def check
    @order = Order.find_by(order_id: params[:orderId])
    @product = Product.find_by(id: @order.product_id)
    transactionId = params[:transactionId]
    @con = JSON.parse(@order.confirm(transactionId).body)

    if @con["returnMessage"] == "Success."
      @order.check
      @order.save
      redirect_to  product_order_path(@product, @order)
    end
  end
end

# rder82ce8313-1bf6-4d64-b133-13d4e136f27a