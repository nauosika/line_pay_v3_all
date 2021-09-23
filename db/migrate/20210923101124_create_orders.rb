class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.integer :total_amount
      t.string :currency, default: "TWD"
      t.string :order_id
      t.string :packages_id
      t.string :name
      t.integer :quantity
      t.integer :price
      t.integer :product_id

      t.timestamps
    end
  end
end
