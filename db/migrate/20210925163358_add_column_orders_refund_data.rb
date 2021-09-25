class AddColumnOrdersRefundData < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :refund_id, :integer
    add_column :orders, :refund_date, :string
    add_column :orders, :regKey, :string
  end
end
