module ProductsHelper
  def owner?(product)
    product.user == current_user
  end

  def buyer?(product)
    product.user != current_user
  end
end
