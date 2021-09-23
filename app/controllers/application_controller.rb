class ApplicationController < ActionController::Base
  def find_product
    @product = Product.find(params[:id])
  end
end
