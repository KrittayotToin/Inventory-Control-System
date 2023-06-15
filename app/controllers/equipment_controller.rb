require 'roo'
require 'axlsx'
require 'date'
# require 'json'

class EquipmentController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def index
    # @equipments = Equipment.all
    @equipments = Equipment.paginate(page: params[:page], per_page: 10)
    @now = Time.new
    @day = Date.today
    puts "Current Time is : #{@now} "
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

  def change_by_input
    json_data = JSON.parse(params[:equipments])

    json_data.each do |equipment_data|
      equipment_code = equipment_data['equipment_code']
      puts "#{equipment_code}".colorize(:green)

      existing_equipment = Equipment.find_by(equipment_code: equipment_code)
      puts "Equipment: #{existing_equipment}".colorize(:red)

      existing_equipment.update(
        equipment_code: equipment_data['equipment_code'],
        equipment_name: equipment_data['equipment_name'],
        equipment_type: equipment_data['equipment_type'],
        equipment_serial_number: equipment_data['equipment_serial_number']
      )

      puts "Equipment Code: #{existing_equipment.equipment_code}"
      puts "Equipment Name: #{existing_equipment.equipment_name}"
      puts "Equipment Type: #{existing_equipment.equipment_type}"
      puts "Equipment Serial Number: #{existing_equipment.equipment_serial_number}"
      puts "-----------------------"
    end

    redirect_to equipment_index_path
    # render json: { message: 'Equipment updated successfully' }
  end



  def destroy

    @equipment = Equipment.find(params[:id])
    @equipment.destroy

    redirect_to equipment_index_path
  end

  def export_to_excel
    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: 'Equipment Data') do |sheet|
      sheet.add_row(['equipment_name', 'equipment_code', 'equipment_serial_number', 'equipment_type'])

      @equipment = Equipment.all

      @equipment.each do |equipment|

        sheet.add_row([equipment.equipment_name, equipment.equipment_code, equipment.equipment_serial_number, equipment.equipment_type])
      end
    end

    file_path = Rails.root.join('public', 'equipment_data.xlsx')
    p.serialize(file_path)

    send_file file_path, filename: 'equipment_data.xlsx', type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end


  def process_excel
    # Retrieve the uploaded file from the request
    excel_file = params[:excel_file]

    # Create a new instance of the appropriate Roo class based on the file format
    workbook = Roo::Spreadsheet.open(excel_file.tempfile, extension: :xlsx) # Adjust the extension if your file is in a different format

    # Extract the first sheet
    sheet = workbook.sheet(0)

    # Retrieve the key-value pairs from the first row
    keys = sheet.row(1)
    # values = sheet.row(2)

    data_rows = []

    # Iterate over the rows, starting from the third row
    (2..sheet.last_row).each do |row_num|
      values = sheet.row(row_num)
      data_row = Hash[keys.zip(values)]
      #การใช้ Hash[keys.zip(values)]
      # keys = ['name', 'age', 'gender']
      # values = ['John', 25, 'Male']

      # data_row = Hash[keys.zip(values)]

      # puts data_row['name']     # Output: John
      # puts data_row['age']      # Output: 25
      # puts data_row['gender']   # Output: Male
      data_rows << data_row
      Rails.logger.info("Extracted data from row #{row_num}: #{data_row}")


      # equipment_code = data_row['equipment_code']
      # equipment = Equipment.find_by(equipment_code: equipment_code)
      # puts " equipment detail: #{equipment}"
      # equipment.update(equipment_code: data_row["equipment_code"], equipment_name: data_row["equipment_name"], equipment_type: data_row["equipment_type"], equipment_serial_number: data_row["equipment_serial_number"])

      # Perform any required operations with each data_row
      obj_data = {
        equipment_code: data_row['equipment_code'],
        equipment_name: data_row['equipment_name'],
        equipment_type: data_row['equipment_type'],
        equipment_serial_number: data_row['equipment_serial_number']
      }

      data_rows << obj_data
    end

    # JSON.pretty_generate pretty object in logs
    obj_data = JSON.pretty_generate(data_rows)
    puts "excel_equipment: #{obj_data}".colorize(:green)
    #check type of data JSON should be Array nah not String
    puts obj_data.class

    equipment_json = JSON.parse(obj_data)
    puts "equipment_json: #{JSON.pretty_generate(equipment_json)}".colorize(:green)
    puts equipment_json.class
    # Iterate over each equipment object in the array
    equipment_json.each do |equipment_data|
      equipment_code = equipment_data['equipment_code']
      puts "CODE: #{equipment_code}"
      equipment = Equipment.find_by(equipment_code: equipment_code)

      if equipment
        equipment.update(
          equipment_code: equipment_data['equipment_code'],
          equipment_name: equipment_data['equipment_name'],
          equipment_type: equipment_data['equipment_type'],
          equipment_serial_number: equipment_data['equipment_serial_number']
        )

        puts "Equipment Code: #{equipment.equipment_code}"
        puts "Equipment Name: #{equipment.equipment_name}"
        puts "-----------------------"
      else
        puts "Equipment with code #{equipment_code} not found."
      end
    end


    redirect_to equipment_index_path

  end





  private

  def equipment_params
    params.require(:equipment).permit(:equipment_code, :equipment_name, :equipment_type, :equipment_serial_number, :equipment_amount)
  end

end
