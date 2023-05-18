class CreateEquipment < ActiveRecord::Migration[5.2]
  def change
    create_table :equipment do |t|
      t.string :equipment_code
      t.string :equipment_type
      t.string :equipment_name
      t.string :equipment_serial_number
      t.integer :equipment_amount

      t.timestamps
    end
  end
end
