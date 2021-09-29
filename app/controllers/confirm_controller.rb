class ConfirmController < ApplicationController
  before_action :set_order_and_product, only: [:check]
  before_action :authenticate_user!
  after_action :send_cofirm_mail, only: [:check]

  def check
    transactionId = params[:transactionId]
    response = JSON.parse(@order.confirm_response(transactionId).body)
    if response["returnMessage"] == "Success."
      @order.set_confirm_data(response, current_user.id)
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

  def send_cofirm_mail
    NotifyMailer.confirm_owner_mail(@order).deliver_later
    NotifyMailer.confirm_buyer_mail(@order).deliver_later
  end
end
