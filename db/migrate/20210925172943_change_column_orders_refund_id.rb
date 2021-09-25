class ChangeColumnOrdersRefundId < ActiveRecord::Migration[6.1]
  def change
    change_column :orders, :refund_id, :string
  end
end
