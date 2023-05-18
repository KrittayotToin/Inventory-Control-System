class RemoveEquipmentStatusFromEquipment < ActiveRecord::Migration[5.2]
  def change
    remove_column :equipment, :equipment_status
  end
end
