class NotifyMailer < ApplicationMailer
  def buy_send_owner(order)
    @user = order.user
    @order = order
    mail to:@user.email, subject: "商品購買通知"
  end

  def buy_send_buyer(order)
    @user = User.find(order.buyer_id)
    @order = order
    mail to:@user.email, subject: "購買商品通知"
  end
end
