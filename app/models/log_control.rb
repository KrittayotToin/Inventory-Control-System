class LogControl < ApplicationRecord
    belongs_to :equipment
    belongs_to :member
    # belongs_to :equipment_status
end
