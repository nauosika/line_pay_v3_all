class OrdersController < ApplicationController
  before_action :find_order_product
  before_action :find_order, only: [:linerequest]

  def index
    @orders = @product.orders
  end

  def show
    @order = @product.orders.find(params[:id])
  end

  def create
    @order = Product.find(params[:product_id]).orders.create(order_params)
    if @order.save
      redirect_to product_order_path(@product, @order), notice: "Order was successfully created."
    else
      redirect_to products_path
    end
  end

  def linerequest
    response = JSON.parse(@order.get_response.body)
    if response["returnMessage"] == "Success."
      puts response
      redirect_to response["info"]["paymentUrl"]["web"]
    else
      puts response
    end
  end

  #transactionId
  #paymentAccessToken

  def confitmUrl
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
