class LogControlController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    # @logs = LogControl.includes(:equipment, :member).all
    # @logs = LogControl.joins(:equipment, :member).all
    @logs = LogControl.joins(:equipment, :member).paginate(page: params[:page], per_page: 10)


  end

  def new

  end

  def create
    equipment_id, equipment_name = params[:equipment].split(",")
    member_id, member_name = params[:member].split(",")
    # log_status = "Borrowed"

    @equipment = Equipment.find(equipment_id)
    @equipment.update(equipment_status: "Not Availble")

    Rails.logger.debug ("Equipment ID: #{equipment_id}, Equipment Name: #{equipment_name}").red
    Rails.logger.debug ("Member ID: #{member_id}, Member Name: #{member_name}").blue
    # Rails.logger.debug ("Log Status: #{log_status}").green
    
    @log = LogControl.new(equipment_id: equipment_id, member_id: member_id, log_date: Date.today)
    @log.log_status = "Borrowed"

    if @log.save

      redirect_to log_control_index_path
    else
      logger.error("Error while saving log: #{@log.errors.full_messages}")
      redirect_to log_control_index_path
    end
  end
  
  def return_equipment
    log = LogControl.find(params[:id])
    log.update(log_status: "Returned")
    log.equipment.update(equipment_status: "Available")
    Rails.logger.debug ("Equipment after update: #{log.equipment.inspect}").green
    redirect_to log_control_index_path
  end
  

  def edit
  end

  def update
  end

  def destroy
  end
end

