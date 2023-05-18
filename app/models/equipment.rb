class Equipment < ApplicationRecord
    has_many :log_controls
    has_many :members, through: :log_controls
end
