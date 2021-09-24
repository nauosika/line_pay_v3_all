class RemoveColumnOrder < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :aasm_state
  end
end
