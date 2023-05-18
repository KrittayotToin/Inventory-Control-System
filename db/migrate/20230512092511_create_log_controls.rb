class CreateLogControls < ActiveRecord::Migration[5.2]
  def change
    create_table :log_controls do |t|
      t.integer :equipment_id
      t.integer :member_id
      t.string :log_status
      t.date :log_date

      t.timestamps
    end
  end
end
