class AddUserProductOrderAssociation < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :user_id, :integer
    add_column :orders, :buyer_id, :integer
    add_column :products, :user_id, :integer
  end
end
