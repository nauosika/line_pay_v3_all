module OrdersHelper
  def need_pay
    @order.pending?
  end
end
