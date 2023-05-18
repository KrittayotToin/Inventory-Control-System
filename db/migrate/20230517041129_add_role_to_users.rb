class AddRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role, :integer
    change_column_default :users, :role, 0
  end
end
