module OrdersHelper
  def need_pay
    @order.pending?
  end

  def payed
    @order.confirmed?
  end
end
