

class DashboardController < ApplicationController
  def index
    @equipments = Equipment.count
    @members = Member.count
    @logs = LogControl.where(log_status: "Borrowed").count
    Rails.logger.debug("#{@equipments}".blue)
    
  end
end
