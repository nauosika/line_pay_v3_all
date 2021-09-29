class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :find_product, only: [:edit, :update, :destroy]

  def index
    @products = Product.all.includes([:user])
  end

  def buylists
    @orders = current_user.buylists.includes([:product]).order("id DESC")
  end

  def own_products
    @products = current_user.products
  end

  def show
    begin
      @product = Product.find(params[:id])
      @order = current_user.buylists.new
    rescue
      redirect_to products_path
    end
  end

  def new
    @product = current_user.products.new
  end

  def create
    @product = current_user.products.new(product_params)
    if @product.save
      redirect_to product_path(@product), notice: "建立成功"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to product_path(@product), notice: "修改成功"
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "刪除成功"
  end

  private
  def find_product
    begin
      @product = current_user.products.find(params[:id])
    rescue
      redirect_to products_path
    end
  end

  def product_params
    params.require(:product).permit(:name, :price, :description)
  end
end
