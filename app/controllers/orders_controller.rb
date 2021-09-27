class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_order_product, except: [:linerequest]
  before_action :find_order, only: [:linerequest, :linerefund]

  def index
    begin
      @orders = current_user.products.find(params[:product_id]).orders
    rescue
      redirect_to products_path
    end
  end

  def show
    @order = @product.orders.find(params[:id])
  end

  def create
    @order = @product.user.orders.create(order_params)
    if @order.save
      redirect_to product_order_path(@product, @order), notice: "Order was successfully created."
    else
      redirect_to products_path, notice: "建立失敗"
    end
  end

  def linerequest
    response = JSON.parse(@order.request_response.body)
    if response["returnMessage"] == "Success."
      redirect_to response["info"]["paymentUrl"]["web"]
    else
      redirect_to products_path
    end
  end

  def linerefund
    begin @order.buyer_id == current_user.id
      response = JSON.parse(@order.refund_response.body)
      if response["returnMessage"] == "Success."
        refundTransactionId = response["info"]["refundTransactionId"]
        refundTransactionDate = response["info"]["refundTransactionDate"]
        @order.set_refund_data(refundTransactionId, refundTransactionDate)
        redirect_to product_order_path(@product, @order)
      else
        redirect_to product_order_path(@product, @order), data: { notice: "退款失敗" }
      end
    rescue
      redirect_to products_path
    end
  end

  private
  def find_order_product
    @product = Product.find(params[:product_id])
  end

  def find_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.permit(:quantity, :product_id)
  end
end
