class AddColumnOrderTransactionid < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :transactionid, :string
  end
end
