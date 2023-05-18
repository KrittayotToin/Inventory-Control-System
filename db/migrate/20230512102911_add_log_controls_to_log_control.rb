class AddLogControlsToLogControl < ActiveRecord::Migration[5.2]
  def change
    add_column :log_controls, :amount, :integer
  end
end
