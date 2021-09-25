class RenameColumnOrderRegkey < ActiveRecord::Migration[6.1]
  def change
    rename_column :orders, :regKey, :regkey
  end
end
