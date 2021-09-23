class OrdersController < ApplicationController
  before_action :find_order_product

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

  private
  def find_order_product
    @product = Product.find(params[:product_id])
  end

  def order_params
    params.permit(:quantity, :product_id)
  end

end
