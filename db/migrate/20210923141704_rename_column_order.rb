class RenameColumnOrder < ActiveRecord::Migration[6.1]
  def change
    rename_column :orders, :total_amount, :amount
  end
end
