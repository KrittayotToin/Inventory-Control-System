class EquipmentController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    # @equipments = Equipment.all
    @equipments = Equipment.paginate(page: params[:page], per_page: 10)
  end

  def show
    @equipment = Equipment.find(params[:id])
  end

  def equipment_names
    @equipment_list = Equipment.where(equipment_status: "Available").pluck(:id, :equipment_name )
    render json: @equipment_list

  end
  

  def new
    @equipment = Equipment.new
  end


    def create
    if current_user.admin?
      # Only admin users can create equipment
      @equipment = Equipment.new(equipment_params)
      @equipment.equipment_status = "Available"
      if @equipment.save
        redirect_to equipment_path(@equipment)
      else
        render :new
      end
      # ...
    else
      # Redirect or show an error message for non-admin users
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
  # def create
  #   @equipment = Equipment.new(equipment_params)
  #   @equipment.equipment_status = "Available"
  #   if @equipment.save
  #     redirect_to equipment_path(@equipment)
  #   else
  #     render :new
  #   end
  # end

  def edit
    @equipment = Equipment.find(params[:id])

  end

  def update
    @equipment = Equipment.find(params[:id])
    if @equipment.update(equipment_params)
      flash[:success] = "Equipment was successfully updated."
      redirect_to equipment_index_path
    else
      flash[:error] = "There was an error updating the equipment."
      render :edit
    end
  end
  

  def destroy

    @equipment = Equipment.find(params[:id])
        @equipment.destroy
    
        redirect_to equipment_index_path
  end
  

  private

  def equipment_params
    params.require(:equipment).permit(:equipment_code, :equipment_name, :equipment_type, :equipment_serial_number, :equipment_amount)
  end
end


#should be with auth check role
# equipment_controller.rb
# class EquipmentController < ApplicationController
#   def new
#     if current_user.admin?
#       # Only admin users can access this action
#       @equipment = Equipment.new
#     else
#       # Redirect or show an error message for non-admin users
#       redirect_to root_path, alert: "You are not authorized to perform this action."
#     end
#   end

#   def create
#     if current_user.admin?
#       # Only admin users can create equipment
#       @equipment = Equipment.new(equipment_params)
#       # ...
#     else
#       # Redirect or show an error message for non-admin users
#       redirect_to root_path, alert: "You are not authorized to perform this action."
#     end
#   end
# end
