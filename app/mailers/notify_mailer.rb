class NotifyMailer < ApplicationMailer
  def confirm_owner_mail(order)
    @user = order.user
    @order = order
    mail to:@user.email, subject: "商品購買通知"
  end

  def confirm_buyer_mail(order)
    @user = User.find(order.buyer_id)
    @order = order
    mail to:@user.email, subject: "購買商品通知"
  end

  def refund_owner_mail(order)
    @user = order.user
    @order = order
    mail to:@user.email, subject: "商品退款通知"
  end

  def refund_buyer_mail(order)
    @user = User.find(order.buyer_id)
    @order = order
    mail to:@user.email, subject: "退款商品通知"
  end
end
