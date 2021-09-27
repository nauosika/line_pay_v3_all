module OrdersHelper
  def need_pay
    @order.pending?
  end

  def payed
    @order.confirmed?
  end

  def order_owner?
    @order.user == current_user
  end

  def order_buyer?
    @order.user != current_user
  end
end
