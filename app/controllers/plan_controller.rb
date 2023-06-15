require 'set'
require 'yaml'
class PlanController < ApplicationController
  skip_before_action :verify_authenticity_token
   # protect_from_forgery with: :exception
  def index

    plan = Plan.last
    # plan_text =  YAML.load(plan.package)
    #  data_hash = eval(plan.package)
    #  puts "plan_text : #{eval(plan.package)}"
    # formatted_yaml = YAML.dump(data_hash)
    #  puts "test !!!#{formatted_yaml.class} "
    # puts "#{plan}".colorize(:green)
    # puts "Package: #{plan.package}".colorize(:green)
    puts "test #{YAML.load(plan.package)}"
    package = YAML.load(plan.package)
    @package = YAML.load(plan.package)

    #Plan A is by_weight
    @plan_a = package["by_weight"]
    #Plan B is by_dimension
    @plan_b = package["by_dimension"]
    #Plan C is by_price
    @plan_c = package["by_size"]




    # puts "Package: #{package}".colorize(:green)

    package_pretty_json = JSON.pretty_generate(package)

    # puts "Package: #{package_pretty_json}".colorize(:green)

    package["by_size"].each do |location, values|
      # puts "#{location}".colorize(:red)
      # puts "#{values}".colorize(:red)
      values.each do |weight, couriers|
        # puts "Weight: #{weight}"
        # puts "couriers: #{couriers}"
      end
    end


  end


  def update
    form_plan = params[:form_plan]

    new_package = JSON.pretty_generate(form_plan)
    # puts new_package.colorize(:green)

    plan = Plan.first
    puts "Plan :::#{plan}".colorize(:red)

    # puts "#{package.class}".colorize(:red)

    # Assuming package is an association to an ActiveRecord model
    if plan.update(package: form_plan)
      puts "Package updated successfully"
      redirect_to plan_index_path
    else
      puts "Failed to update package"
    end


    # Perform any necessary processing with the formPlan data
    # ...

    # render json: { message: 'Update successful' }, status: :ok
  end

  #Upload excel plan
  def process_excel
    excel_file = params[:excel_file] # Assuming the file input name is 'file'
    workbook = Roo::Spreadsheet.open(excel_file.tempfile, extension: :xlsx)

    sheet = workbook.sheet(1) # Extract the first sheet

    header_by_weight_row = nil
    header_by_dimension_row = nil
    header_by_size_row = nil

    header_by_weight_col= nil
    header_by_dimension_col= nil
    header_by_size_col= nil

    # puts "sheet cell: #{sheet.cell(1, 26)}"
    # puts "sheet cell: #{sheet.cell(1, 25)}"

    #Loop หา ตำแหน่ง cell ของ by_weight, by_dimension และ by_size สามารถทำให้สั้นลงได้ด้วย methond roo .find
    #Find cell of header in table ** can simplify with sheet.find **
    (sheet.first_row..sheet.last_row).each do |row_index|
      (sheet.first_column..sheet.last_column).each do |col_index|
        row_data = sheet.cell(row_index, col_index)
        # puts "row_data: #{row_data}"

        case
        when row_data == "by_weight"
          # puts "hello"
          # puts "row_index #{row_index}"
          # puts "col_index #{col_index}"
          header_by_weight_row = row_index
          header_by_weight_col = col_index

        when row_data == "by_dimension"
          # puts "hello"
          # puts "row_index #{row_index}"
          # puts "col_index #{col_index}"

          header_by_dimension_row = row_index
          header_by_dimension_col = col_index

        when row_data == "by_size"
          # puts "hello"
          # puts "row_index #{row_index}"
          # puts "col_index #{col_index}"

          header_by_size_row = row_index
          header_by_size_col = col_index


        end
        #Position cell of header in table
        break if header_by_weight_row && header_by_dimension_row && header_by_size_row
      end

    end

    # puts "header_by_weight_row: #{header_by_weight_row}"

    by_weight = sheet.cell(header_by_weight_row, header_by_weight_col)
    by_dimension = sheet.cell(header_by_dimension_row, header_by_dimension_col)
    by_size = sheet.cell(header_by_size_row, header_by_size_col)

    # puts "by_weight: #{by_weight}"
    # puts "by_dimension: #{by_dimension}"
    # puts "by size: #{by_size}"


    #Create ปั้น format เริ่มต้น
    #Find frame each corner
    #Find others to see limit of btm left coner by_weight
    position_others_by_weight = (sheet.column(header_by_weight_col)).compact
    position_others_by_dimension = (sheet.column(header_by_dimension_col)).compact
    position_others_by_size = (sheet.column(header_by_size_col)).compact

    # puts "others : #{position_others_by_weight}"
    # puts "others : #{position_others_by_dimension}"
    # puts "others : #{position_others_by_size}"

    #[0] is name of type example by_weight .. .. ..
    package = {
      position_others_by_weight[0] => {
        "bkk" => {},
        "upc" => {}
      },position_others_by_dimension[0] => {
        "bkk" => {},
        "upc" => {}
      },position_others_by_size[0] => {
        "bkk" => {},
        "upc" => {}
      }
    }

    #Under row ของแต่่ละ header column จะเป็น value หรือว่า teir loop ตั้งแต่  1 เป็นต้นไป เช่น 0 20 ... ไปจนถึง others
    position_others_by_weight[1..].each do |value|
      package[position_others_by_weight[0]]["bkk"][value] = {}
      package[position_others_by_weight[0]]["upc"][value] = {}
      break if value == "others"
    end

    position_others_by_dimension[1..].each do |value|
      package[position_others_by_dimension[0]]["bkk"][value] = {}
      package[position_others_by_dimension[0]]["upc"][value] = {}
      break if value == "others"
    end

    position_others_by_size[1..].each do |value|
      package[position_others_by_size[0]]["bkk"][value] = {}
      package[position_others_by_size[0]]["upc"][value] = {}
      break if value == "others"
    end


    #สำหรับ Add service ของแต่ละประเภท
    #Add service to by_weight bkk and upc
    (header_by_weight_col..header_by_dimension_col).select{|x| header_by_weight_col.odd? ? x.even? : x.odd?}.each do |col_index|
      service = sheet.column(col_index)
      # puts "Col index: #{col_index}"
      # puts "Service: #{service.first}"

      #bAdd service bkk by_weight
      package["by_weight"]["bkk"].each_key do |key|
        if !service.first.nil?
          if key.to_i  > 20000
            service_value = "sky_bulky"
          else
            service_value = service.first
          end

          # puts "Key #{key} is present in result_hash with value #{result_hash[key]}"
          # puts row_tier_by_weight
          # puts result_hash[key], col_index

          package["by_weight"]["bkk"][key][service_value] = {}
          # package["by_weight"]["upc"][key][service_value] = {}

          # package["by_weight"]["upc"][key][service_value] = {}
        end
      end

      #Add service upc by_weight
      package["by_weight"]["upc"].each_key do |key|
        if !service.first.nil?
          if key.to_i  > 20000
            service_value = "sky_bulky"
          else
            service_value = service.first
          end

          # puts "Key #{key} is present in result_hash with value #{result_hash[key]}"
          # puts row_tier_by_weight
          # puts result_hash[key], col_index

          # package["by_weight"]["bkk"][key][service_value] = {}
          package["by_weight"]["upc"][key][service_value] = {}

          # package["by_weight"]["upc"][key][service_value] = {}
        end
      end

    end

    #Add service to by_dimension bkk and upc
    (header_by_dimension_col..header_by_size_col).select{|x| header_by_weight_col.odd? ? x.even? : x.odd?}.each do |col_index|
      service =  sheet.column(col_index)
      # puts "Col index: #{col_index}"
      # puts "Service: #{service.first}"


      #Add service bkk by_dimension
      package["by_dimension"]["bkk"].each_key do |key|
        if !service.first.nil?
          if key.to_i  > 280
            service_value = ["sky_bulky", "sky_fruit"]
          else
            service_value = service.first
          end

          if  service_value.is_a?(Array)
            service_value.each do |service|
              package["by_dimension"]["bkk"][key][service] = {}
            end
          else
            package["by_dimension"]["bkk"][key][service_value] = {}
          end

        end
      end

      #Add service upc by_dimension
      package["by_dimension"]["upc"].each_key do |key|
        if !service.first.nil?
          if key.to_i  > 280
            service_value = ["sky_bulky", "sky_fruit"]
          else
            service_value = service.first
          end

          if  service_value.is_a?(Array)
            service_value.each do |service|
              package["by_dimension"]["upc"][key][service] = {}
            end
          else
            package["by_dimension"]["upc"][key][service_value] = {}
          end

        end
      end
    end


    #Add service to by_size bkk and upc only thaipost_one 13 Jun
    #Add service bkk by_size
    package["by_size"]["bkk"].each_key do |key|
      service_value = "thaipost_one"
      package["by_size"]["bkk"][key][service_value] = {}
    end

    #Add service upc by_size
    package["by_size"]["upc"].each_key do |key|
      service_value = "thaipost_one"
      package["by_size"]["upc"][key][service_value] = {}
    end


    #Add ราคาของแต่ละ service ทุกๆ tier
    #Add data or price in service each tier

    #Add price by_weight
    bkk_row_by_weight = header_by_weight_row + 2
    bkk_col_by_weight = header_by_weight_col + 1

    package["by_weight"]["bkk"].each_key do |key|
      if key.to_i > 20000
        bkk_col_by_weight = header_by_weight_col + 13 #col with sky_bulky bkk by_weight
        package["by_weight"]["bkk"][key]["sky_bulky"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight)
        bkk_row_by_weight += 1
      elsif key == "others"
        others_row = bkk_row_by_weight
        # puts others_row
        bkk_col_by_weight = header_by_weight_col + 1


        ##สามารถทำฟังชั่นก์กลางได้ ในการ sheet.cell
        package["by_weight"]["bkk"][key]["ems"] = sheet.cell(others_row, bkk_col_by_weight)
        package["by_weight"]["bkk"][key]["ecopost"] = sheet.cell(others_row, bkk_col_by_weight + 2)
        package["by_weight"]["bkk"][key]["flashexpress"] = sheet.cell(others_row, bkk_col_by_weight + 4)
        package["by_weight"]["bkk"][key]["thaipost_one"] = sheet.cell(others_row, bkk_col_by_weight + 6)
        package["by_weight"]["bkk"][key]["ninjavan"] = sheet.cell(others_row, bkk_col_by_weight + 8)
        package["by_weight"]["bkk"][key]["register"] = sheet.cell(others_row, bkk_col_by_weight + 10)
        package["by_weight"]["bkk"][key]["sky_bulky"] = sheet.cell(others_row, bkk_col_by_weight + 12)
        package["by_weight"]["bkk"][key]["jt_express"] = sheet.cell(others_row, bkk_col_by_weight + 14)

      else
        package["by_weight"]["bkk"][key]["ems"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight)
        package["by_weight"]["bkk"][key]["ecopost"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 2)
        package["by_weight"]["bkk"][key]["flashexpress"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 4)
        package["by_weight"]["bkk"][key]["thaipost_one"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 6)
        package["by_weight"]["bkk"][key]["ninjavan"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 8)
        package["by_weight"]["bkk"][key]["register"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 10)
        package["by_weight"]["bkk"][key]["sky_bulky"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 12)
        package["by_weight"]["bkk"][key]["jt_express"] = sheet.cell(bkk_row_by_weight, bkk_col_by_weight + 14)

        bkk_row_by_weight += 1
      end

    end

    upc_row_by_weight = header_by_weight_row + 2
    upc_col_by_weight = header_by_weight_col + 2

    package["by_weight"]["upc"].each_key do |key|
      if key.to_i > 20000
        upc_col_by_weight = header_by_weight_col + 14 #col with sky_bulky bkk by_weight
        package["by_weight"]["upc"][key]["sky_bulky"] = sheet.cell(upc_row_by_weight, upc_col_by_weight)
        upc_row_by_weight += 1

      elsif key == "others"
        others_row = upc_row_by_weight
        # puts others_row
        upc_col_by_weight = header_by_weight_col + 2

        package["by_weight"]["upc"][key]["ems"] = sheet.cell(others_row, upc_col_by_weight)
        package["by_weight"]["upc"][key]["ecopost"] = sheet.cell(others_row, upc_col_by_weight + 2)
        package["by_weight"]["upc"][key]["flashexpress"] = sheet.cell(others_row, upc_col_by_weight + 4)
        package["by_weight"]["upc"][key]["thaipost_one"] = sheet.cell(others_row, upc_col_by_weight + 6)
        package["by_weight"]["upc"][key]["ninjavan"] = sheet.cell(others_row, upc_col_by_weight + 8)
        package["by_weight"]["upc"][key]["register"] = sheet.cell(others_row, upc_col_by_weight + 10)
        package["by_weight"]["upc"][key]["sky_bulky"] = sheet.cell(others_row, upc_col_by_weight + 12)
        package["by_weight"]["upc"][key]["jt_express"] = sheet.cell(others_row, upc_col_by_weight + 14)
      else
        package["by_weight"]["upc"][key]["ems"] = sheet.cell(upc_row_by_weight, upc_col_by_weight)
        package["by_weight"]["upc"][key]["ecopost"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 2)
        package["by_weight"]["upc"][key]["flashexpress"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 4)
        package["by_weight"]["upc"][key]["thaipost_one"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 6)
        package["by_weight"]["upc"][key]["ninjavan"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 8)
        package["by_weight"]["upc"][key]["register"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 10)
        package["by_weight"]["upc"][key]["sky_bulky"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 12)
        package["by_weight"]["upc"][key]["jt_express"] = sheet.cell(upc_row_by_weight, upc_col_by_weight + 14)

        upc_row_by_weight += 1
      end

    end


    #Add price by_dimension

    bkk_row_by_dimension = header_by_dimension_row + 2
    bkk_col_by_dimension = header_by_dimension_col + 1
    # puts "col :"
    # puts bkk_col_by_dimension

    package["by_dimension"]["bkk"].each_key do |key|
      if key.to_i > 280
        bkk_col_by_dimension = header_by_dimension_col + 13 #col with sky_bulky bkk by_dimension
        package["by_dimension"]["bkk"][key]["sky_bulky"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension)
        package["by_dimension"]["bkk"][key]["sky_fruit"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension)
        bkk_row_by_dimension += 1
      elsif key == "others"
        others_row = bkk_row_by_dimension
        # puts others_row
        bkk_col_by_dimension = header_by_dimension_col + 1

        package["by_dimension"]["bkk"][key]["ems"] = sheet.cell(others_row, bkk_col_by_dimension)
        package["by_dimension"]["bkk"][key]["ecopost"] = sheet.cell(others_row, bkk_col_by_dimension + 2)
        package["by_dimension"]["bkk"][key]["register"] = sheet.cell(others_row, bkk_col_by_dimension + 4)
        package["by_dimension"]["bkk"][key]["ninjavan"] = sheet.cell(others_row, bkk_col_by_dimension + 6)
        package["by_dimension"]["bkk"][key]["thaipost_one"] = sheet.cell(others_row, bkk_col_by_dimension + 8)
        package["by_dimension"]["bkk"][key]["flashexpress"] = sheet.cell(others_row, bkk_col_by_dimension + 10)
        package["by_dimension"]["bkk"][key]["sky_bulky"] = sheet.cell(others_row, bkk_col_by_dimension + 12)
        package["by_dimension"]["bkk"][key]["sky_fruit"] = sheet.cell(others_row, bkk_col_by_dimension + 14)

      else
        package["by_dimension"]["bkk"][key]["ems"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension)
        package["by_dimension"]["bkk"][key]["ecopost"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 2)
        package["by_dimension"]["bkk"][key]["register"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 4)
        package["by_dimension"]["bkk"][key]["ninjavan"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 6)
        package["by_dimension"]["bkk"][key]["thaipost_one"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 8)
        package["by_dimension"]["bkk"][key]["flashexpress"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 10)
        package["by_dimension"]["bkk"][key]["sky_bulky"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 12)
        package["by_dimension"]["bkk"][key]["sky_fruit"] = sheet.cell(bkk_row_by_dimension, bkk_col_by_dimension + 14)

        bkk_row_by_dimension += 1
      end

    end

    upc_row_by_dimension = header_by_dimension_row + 2
    upc_col_by_dimension = header_by_dimension_col + 2

    package["by_dimension"]["upc"].each_key do |key|
      if key.to_i > 280
        upc_col_by_dimension = header_by_dimension_col + 14 #col with sky_bulky bkk by_dimension
        package["by_dimension"]["upc"][key]["sky_bulky"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension)
        package["by_dimension"]["upc"][key]["sky_fruit"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension)
        upc_row_by_dimension += 1

      elsif key == "others"
        others_row = upc_row_by_dimension
        # puts others_row
        upc_col_by_dimension = header_by_dimension_col + 2

        package["by_dimension"]["upc"][key]["ems"] = sheet.cell(others_row, upc_col_by_dimension)
        package["by_dimension"]["upc"][key]["ecopost"] = sheet.cell(others_row, upc_col_by_dimension + 2)
        package["by_dimension"]["upc"][key]["register"] = sheet.cell(others_row, upc_col_by_dimension + 4)
        package["by_dimension"]["upc"][key]["ninjavan"] = sheet.cell(others_row, upc_col_by_dimension + 6)
        package["by_dimension"]["upc"][key]["thaipost_one"] = sheet.cell(others_row, upc_col_by_dimension + 8)
        package["by_dimension"]["upc"][key]["flashexpress"] = sheet.cell(others_row, upc_col_by_dimension + 10)
        package["by_dimension"]["upc"][key]["sky_bulky"] = sheet.cell(others_row, upc_col_by_dimension + 12)
        package["by_dimension"]["upc"][key]["sky_fruit"] = sheet.cell(others_row, upc_col_by_dimension + 14)
      else
        package["by_dimension"]["upc"][key]["ems"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension)
        package["by_dimension"]["upc"][key]["ecopost"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 2)
        package["by_dimension"]["upc"][key]["register"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 4)
        package["by_dimension"]["upc"][key]["ninjavan"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 6)
        package["by_dimension"]["upc"][key]["thaipost_one"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 8)
        package["by_dimension"]["upc"][key]["flashexpress"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 10)
        package["by_dimension"]["upc"][key]["sky_bulky"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 12)
        package["by_dimension"]["upc"][key]["sky_fruit"] = sheet.cell(upc_row_by_dimension, upc_col_by_dimension + 14)

        upc_row_by_dimension += 1
      end

    end

    #Add price by_size
    # puts header_by_size_col
    bkk_row_by_size = header_by_size_row + 2
    bkk_col_by_size = header_by_size_col + 1

    package["by_size"]["bkk"].each_key do |key|
      if key == "others"
        others_row = bkk_row_by_size

        bkk_col_by_size = header_by_size_col + 1

        package["by_size"]["bkk"][key]["thaipost_one"] = sheet.cell(others_row, bkk_col_by_size)
      else
        package["by_size"]["bkk"][key]["thaipost_one"] = sheet.cell(bkk_row_by_size, bkk_col_by_size)
        bkk_row_by_size += 1

      end

    end

    upc_row_by_size = header_by_size_row + 2
    upc_col_by_size = header_by_size_col + 2

    package["by_size"]["upc"].each_key do |key|
      if key == "others"
        others_row =upc_row_by_size

        upc_col_by_size = header_by_size_col + 2

        package["by_size"]["upc"][key]["thaipost_one"] = sheet.cell(others_row,upc_col_by_size)
      else

        package["by_size"]["upc"][key]["thaipost_one"] = sheet.cell(upc_row_by_size,upc_col_by_size)
        upc_row_by_size += 1

      end

    end

    # puts JSON.pretty_generate(package)

    package_yaml = package.to_yaml
    puts package_yaml


    plan = Plan.first
    if plan.update(package: package_yaml)
      puts "Package updated successfully"
      redirect_to plan_index_path
    else
      puts "Failed to update package"
    end




  end



  # def process_excel
  #   # Retrieve the uploaded file from the request
  #   excel_file = params[:excel_file]
  #   puts "excel_file: #{excel_file}"


  #   # Create a new instance of the appropriate Roo class based on the file format
  #   workbook = Roo::Spreadsheet.open(excel_file.tempfile, extension: :xlsx) # Adjust the extension if your file is in a different format

  #   # Extract the first sheet
  #   sheet = workbook.sheet(0)

  #   # Retrieve the value in row 1, column 1
  #   key_by_weight = sheet.cell(1,1)

  #   key_by_dimesion = sheet.cell(31,1)

  #   key_by_size = sheet.cell(60,1)


  #   puts "key: #{key_by_weight}".colorize(:green)
  #   puts "key: #{key_by_dimesion}".colorize(:green)
  #   puts "key: #{key_by_size}".colorize(:green)
  #   # values = sheet.row(2)
  #   # Specify the range of cells

  #   #get weight key by_weight
  #   start_row = 3
  #   end_row = 29
  #   column_number = 1
  #   weights = []  # Initialize an empty array to collect the weight values

  #   (start_row..end_row).each do |row|
  #     weight = sheet.cell(row, column_number)
  #     weights << weight  # Add the weight value to the array
  #   end

  #   puts "Weights: #{weights}"  # Print the collected weight values

  #   #get weight key by_dimension
  #   start_row_dimension = 33
  #   end_row_dimension = 58
  #   column_number_dimension = 1
  #   weights_by_dimension = []  # Initialize an empty array to collect the weight values

  #   (start_row_dimension..end_row_dimension).each do |row|
  #     weight = sheet.cell(row, column_number_dimension)
  #     weights_by_dimension << weight  # Add the weight value to the array
  #   end

  #   puts "weights_by_dimension: #{weights_by_dimension}"

  #   #get weight key by_dimension
  #   start_row_size = 62
  #   end_row_size = 70
  #   column_number_size = 1
  #   weights_by_size = []  # Initialize an empty array to collect the weight values

  #   (start_row_size..end_row_size).each do |row|
  #     weight = sheet.cell(row, column_number_size)
  #     weights_by_size << weight  # Add the weight value to the array
  #   end

  #   puts "weights_by_size: #{weights_by_size}"

  #   #Loop for province
  #   start_column = 2
  #   end_column = 22
  #   row_number = 2

  #   # Retrieve the values in the specified range
  #   provinces = (start_column..end_column).map { |column| sheet.cell(row_number, column) }
  #   province = provinces.uniq

  #   puts "province: #{province}"



  #   #Loop for province
  #   start_column_province = 2
  #   end_column_province = 23
  #   row_number_province = 1

  #   # Retrieve the values in the specified range
  #   transports = (start_column_province..end_column_province).map { |column| sheet.cell(row_number_province, column) }
  #   transport = transports.uniq

  #   puts "transport uniq: #{transport}"

  #   #loop ems to bts
  #   #data of by_weight 0 bkk upc
  #   by_weight_0_bkk, by_weight_0_upc = middleware_plan_excel(sheet, 2, 23, 3)

  #   puts "Data by_weight 0 bkk: #{by_weight_0_bkk}"
  #   puts "Data by_weight 0 upc: #{by_weight_0_upc}"

  #   #data of by_weight 20 bkk
  #   by_weight_20_bkk, by_weight_20_upc = middleware_plan_excel(sheet, 2, 23, 4)
  #   puts "Data by_weight 20 bkk: #{by_weight_20_bkk}"
  #   puts "Data by_weight 20 upc: #{by_weight_20_upc}"


  #   #data of by_weight 50 bkk
  #   by_weight_50_bkk, by_weight_50_upc = middleware_plan_excel(sheet, 2, 23, 5)

  #   puts "Data by_weight 50 bkk: #{by_weight_50_bkk}"
  #   puts "Data by_weight 50 upc: #{by_weight_50_upc}"

  #   #data of by_weight 100 bkk
  #   by_weight_100_bkk, by_weight_100_upc = middleware_plan_excel(sheet, 2, 23, 6)

  #   puts "Data by_weight 100 bkk: #{by_weight_100_bkk}"
  #   puts "Data by_weight 100 upc: #{by_weight_100_upc}"

  #   #data of by_weight 250 bkk
  #   by_weight_250_bkk, by_weight_250_upc = middleware_plan_excel(sheet, 2, 23, 7)

  #   puts "Data by_weight 250 bkk: #{by_weight_250_bkk}"
  #   puts "Data by_weight 250 upc: #{by_weight_250_upc}"

  #   #data of by_weight 500 bkk
  #   by_weight_500_bkk, by_weight_500_upc = middleware_plan_excel(sheet, 2, 23, 8)

  #   puts "Data by_weight 500 bkk: #{by_weight_500_bkk}"
  #   puts "Data by_weight 500 upc: #{by_weight_500_upc}"

  #   #data of by_weight 1000 bkk
  #   by_weight_1000_bkk, by_weight_1000_upc = middleware_plan_excel(sheet, 2, 23, 9)

  #   puts "Data by_weight 1000 bkk: #{by_weight_1000_bkk}"
  #   puts "Data by_weight 1000 upc: #{by_weight_1000_upc}"

  #   #data of by_weight 2000 bkk
  #   by_weight_2000_bkk, by_weight_2000_upc = middleware_plan_excel(sheet, 2, 23, 10)

  #   puts "Data by_weight 2000 bkk: #{by_weight_2000_bkk}"
  #   puts "Data by_weight 2000 upc: #{by_weight_2000_upc}"

  #   #data of by_weight 3000 bkk

  #   by_weight_3000_bkk, by_weight_3000_upc = middleware_plan_excel(sheet, 2, 23, 11)

  #   puts "Data by_weight 3000 bkk: #{by_weight_3000_bkk}"
  #   puts "Data by_weight 3000 upc: #{by_weight_3000_upc}"

  #   #data of by_weight 4000 bkk
  #   by_weight_4000_bkk, by_weight_4000_upc = middleware_plan_excel(sheet, 2, 23, 12)

  #   puts "Data by_weight 4000 bkk: #{by_weight_4000_bkk}"
  #   puts "Data by_weight 4000 upc: #{by_weight_4000_upc}"

  #   #data of by_weight 5000 bkk
  #   by_weight_5000_bkk, by_weight_5000_upc = middleware_plan_excel(sheet, 2, 23, 13)

  #   puts "Data by_weight 5000 bkk: #{by_weight_5000_bkk}"
  #   puts "Data by_weight 5000 upc: #{by_weight_5000_upc}"

  #   #data of by_weight 6000 bkk
  #   by_weight_6000_bkk, by_weight_6000_upc = middleware_plan_excel(sheet, 2, 23, 14)

  #   puts "Data by_weight 6000 bkk: #{by_weight_6000_bkk}"
  #   puts "Data by_weight 6000 upc: #{by_weight_6000_upc}"

  #   #data of by_weight 7000 bkk
  #   by_weight_7000_bkk, by_weight_7000_upc = middleware_plan_excel(sheet, 2, 23, 15)

  #   puts "Data by_weight 7000 bkk: #{by_weight_7000_bkk}"
  #   puts "Data by_weight 7000 upc: #{by_weight_7000_upc}"


  #   #data of by_weight 8000 bkk
  #   by_weight_8000_bkk, by_weight_8000_upc = middleware_plan_excel(sheet, 2, 23, 16)

  #   puts "Data by_weight 8000 bkk: #{by_weight_8000_bkk}"
  #   puts "Data by_weight 8000 upc: #{by_weight_8000_upc}"

  #   #data of by_weight 9000 bkk
  #   by_weight_9000_bkk, by_weight_9000_upc = middleware_plan_excel(sheet, 2, 23, 17)

  #   puts "Data by_weight 9000 bkk: #{by_weight_9000_bkk}"
  #   puts "Data by_weight 9000 upc: #{by_weight_9000_upc}"

  #   #data of by_weight 10000 bkk
  #   by_weight_10000_bkk, by_weight_10000_upc = middleware_plan_excel(sheet, 2, 23, 18)

  #   puts "Data by_weight 10000 bkk: #{by_weight_10000_bkk}"
  #   puts "Data by_weight 10000 upc: #{by_weight_10000_upc}"

  #   #data of by_weight 11000 bkk
  #   by_weight_11000_bkk, by_weight_11000_upc = middleware_plan_excel(sheet, 2, 23, 19)

  #   puts "Data by_weight 11000 bkk: #{by_weight_11000_bkk}"
  #   puts "Data by_weight 11000 upc: #{by_weight_11000_upc}"

  #   #data of by_weight 12000 bkk
  #   by_weight_12000_bkk, by_weight_12000_upc = middleware_plan_excel(sheet, 2, 23, 20)

  #   puts "Data by_weight 12000 bkk: #{by_weight_12000_bkk}"
  #   puts "Data by_weight 12000 upc: #{by_weight_12000_upc}"

  #   #data of by_weight 13000 bkk
  #   by_weight_13000_bkk, by_weight_13000_upc = middleware_plan_excel(sheet, 2, 23, 21)

  #   puts "Data by_weight 13000 bkk: #{by_weight_13000_bkk}"
  #   puts "Data by_weight 13000 upc: #{by_weight_13000_upc}"

  #   #data of by_weight 14000 bkk
  #   by_weight_14000_bkk, by_weight_14000_upc = middleware_plan_excel(sheet, 2, 23, 22)

  #   puts "Data by_weight 14000 bkk: #{by_weight_14000_bkk}"
  #   puts "Data by_weight 14000 upc: #{by_weight_14000_upc}"

  #   #data of by_weight 15000 bkk
  #   by_weight_15000_bkk, by_weight_15000_upc = middleware_plan_excel(sheet, 2, 23, 23)

  #   puts "Data by_weight 15000 bkk: #{by_weight_15000_bkk}"
  #   puts "Data by_weight 15000 upc: #{by_weight_15000_upc}"

  #   #data of by_weight 16000 bkk
  #   by_weight_16000_bkk, by_weight_16000_upc = middleware_plan_excel(sheet, 2, 23, 24)

  #   puts "Data by_weight 16000 bkk: #{by_weight_16000_bkk}"
  #   puts "Data by_weight 16000 upc: #{by_weight_16000_upc}"

  #   #data of by_weight 17000 bkk
  #   by_weight_17000_bkk, by_weight_17000_upc = middleware_plan_excel(sheet, 2, 23, 25)

  #   puts "Data by_weight 17000 bkk: #{by_weight_17000_bkk}"
  #   puts "Data by_weight 17000 upc: #{by_weight_17000_upc}"

  #   #data of by_weight 18000 bkk
  #   by_weight_18000_bkk, by_weight_18000_upc = middleware_plan_excel(sheet, 2, 23, 26)

  #   puts "Data by_weight 18000 bkk: #{by_weight_18000_bkk}"
  #   puts "Data by_weight 18000 upc: #{by_weight_18000_upc}"

  #   #data of by_weight 19000 bkk
  #   by_weight_19000_bkk, by_weight_19000_upc = middleware_plan_excel(sheet, 2, 23, 27)

  #   puts "Data by_weight 19000 bkk: #{by_weight_19000_bkk}"
  #   puts "Data by_weight 19000 upc: #{by_weight_19000_upc}"

  #   #data of by_weight 20000 bkk
  #   by_weight_20000_bkk, by_weight_20000_upc = middleware_plan_excel(sheet, 2, 23, 28)

  #   puts "Data by_weight 20000 bkk: #{by_weight_20000_bkk}"
  #   puts "Data by_weight 20000 upc: #{by_weight_20000_upc}"

  #   #data of by_weight others bkk
  #   by_weight_others_bkk, by_weight_others_upc = middleware_plan_excel(sheet, 2, 23, 29)

  #   puts "Data by_weight others bkk: #{by_weight_others_bkk}"
  #   puts "Data by_weight others upc: #{by_weight_others_upc}"


  #   # Data of by_dimension 20 bkk
  #   by_dimension_20_bkk_even, by_dimension_20_upc_odd = middleware_plan_excel(sheet, 2, 23, 33)

  #   puts "Data by_dimension 20 bkk (Even): #{by_dimension_20_bkk_even}"
  #   puts "Data by_dimension 20 upc (Odd): #{by_dimension_20_upc_odd}"

  #   # Data of by_dimension 35 bkk
  #   by_dimension_35_bkk_even, by_dimension_35_upc_odd = middleware_plan_excel(sheet, 2, 23, 34)

  #   puts "Data by_dimension 35 bkk (Even): #{by_dimension_35_bkk_even}"
  #   puts "Data by_dimension 35 upc (Odd): #{by_dimension_35_upc_odd}"

  #   # Data of by_dimension 40 bkk
  #   by_dimension_40_bkk_even, by_dimension_40_upc_odd = middleware_plan_excel(sheet, 2, 23, 35)

  #   puts "Data by_dimension 40 bkk (Even): #{by_dimension_40_bkk_even}"
  #   puts "Data by_dimension 40 upc (Odd): #{by_dimension_40_upc_odd}"

  #   # Data of by_dimension 45 bkk
  #   by_dimension_45_bkk_even, by_dimension_45_upc_odd = middleware_plan_excel(sheet, 2, 23, 36)

  #   puts "Data by_dimension 45 bkk (Even): #{by_dimension_45_bkk_even}"
  #   puts "Data by_dimension 45 upc (Odd): #{by_dimension_45_upc_odd}"

  #   # Data of by_dimension 55 bkk
  #   by_dimension_55_bkk_even, by_dimension_55_upc_odd = middleware_plan_excel(sheet, 2, 23, 37)

  #   puts "Data by_dimension 55 bkk (Even): #{by_dimension_55_bkk_even}"
  #   puts "Data by_dimension 55 upc (Odd): #{by_dimension_55_upc_odd}"

  #   # Data of by_dimension 65 bkk
  #   by_dimension_65_bkk_even, by_dimension_65_upc_odd = middleware_plan_excel(sheet, 2, 23, 38)

  #   puts "Data by_dimension 65 bkk (Even): #{by_dimension_65_bkk_even}"
  #   puts "Data by_dimension 65 upc (Odd): #{by_dimension_65_upc_odd}"

  #   # Data of by_dimension 75 bkk
  #   by_dimension_75_bkk_even, by_dimension_75_upc_odd = middleware_plan_excel(sheet, 2, 23, 39)

  #   puts "Data by_dimension 75 bkk (Even): #{by_dimension_75_bkk_even}"
  #   puts "Data by_dimension 75 upc (Odd): #{by_dimension_75_upc_odd}"

  #   # Data of by_dimension 85 bkk
  #   by_dimension_85_bkk_even, by_dimension_85_upc_odd = middleware_plan_excel(sheet, 2, 23, 40)

  #   puts "Data by_dimension 85 bkk (Even): #{by_dimension_85_bkk_even}"
  #   puts "Data by_dimension 85 upc (Odd): #{by_dimension_85_upc_odd}"

  #   # Data of by_dimension 90 bkk
  #   by_dimension_90_bkk_even, by_dimension_90_upc_odd = middleware_plan_excel(sheet, 2, 23, 41)

  #   puts "Data by_dimension 90 bkk (Even): #{by_dimension_90_bkk_even}"
  #   puts "Data by_dimension 90 upc (Odd): #{by_dimension_90_upc_odd}"

  #   # Data of by_dimension 95 bkk
  #   by_dimension_95_bkk_even, by_dimension_95_upc_odd = middleware_plan_excel(sheet, 2, 23, 42)

  #   puts "Data by_dimension 95 bkk (Even): #{by_dimension_95_bkk_even}"
  #   puts "Data by_dimension 95 upc (Odd): #{by_dimension_95_upc_odd}"

  #   # Data of by_dimension 100 bkk
  #   by_dimension_100_bkk_even, by_dimension_100_upc_odd = middleware_plan_excel(sheet, 2, 23, 43)

  #   puts "Data by_dimension 100 bkk (Even): #{by_dimension_100_bkk_even}"
  #   puts "Data by_dimension 100 upc (Odd): #{by_dimension_100_upc_odd}"

  #   # Data of by_dimension 105 bkk
  #   by_dimension_105_bkk_even, by_dimension_105_upc_odd = middleware_plan_excel(sheet, 2, 23, 44)

  #   puts "Data by_dimension 105 bkk (Even): #{by_dimension_105_bkk_even}"
  #   puts "Data by_dimension 105 upc (Odd): #{by_dimension_105_upc_odd}"

  #   # Data of by_dimension 110 bkk
  #   by_dimension_110_bkk_even, by_dimension_110_upc_odd = middleware_plan_excel(sheet, 2, 23, 45)

  #   puts "Data by_dimension 110 bkk (Even): #{by_dimension_110_bkk_even}"
  #   puts "Data by_dimension 110 upc (Odd): #{by_dimension_110_upc_odd}"

  #   # Data of by_dimension 115 bkk
  #   by_dimension_115_bkk_even, by_dimension_115_upc_odd = middleware_plan_excel(sheet, 2, 23, 46)

  #   puts "Data by_dimension 115 bkk (Even): #{by_dimension_115_bkk_even}"
  #   puts "Data by_dimension 115 upc (Odd): #{by_dimension_115_upc_odd}"

  #   # Data of by_dimension 120 bkk
  #   by_dimension_120_bkk_even, by_dimension_120_upc_odd = middleware_plan_excel(sheet, 2, 23, 47)

  #   puts "Data by_dimension 120 bkk (Even): #{by_dimension_120_bkk_even}"
  #   puts "Data by_dimension 120 upc (Odd): #{by_dimension_120_upc_odd}"

  #   # Data of by_dimension 125 bkk
  #   by_dimension_125_bkk_even, by_dimension_125_upc_odd = middleware_plan_excel(sheet, 2, 23, 48)

  #   puts "Data by_dimension 125 bkk (Even): #{by_dimension_125_bkk_even}"
  #   puts "Data by_dimension 125 upc (Odd): #{by_dimension_125_upc_odd}"

  #   # Data of by_dimension 130 bkk
  #   by_dimension_130_bkk_even, by_dimension_130_upc_odd = middleware_plan_excel(sheet, 2, 23, 49)

  #   puts "Data by_dimension 130 bkk (Even): #{by_dimension_130_bkk_even}"
  #   puts "Data by_dimension 130 upc (Odd): #{by_dimension_130_upc_odd}"

  #   # Data of by_dimension 135 bkk
  #   by_dimension_135_bkk_even, by_dimension_135_upc_odd = middleware_plan_excel(sheet, 2, 23, 50)

  #   puts "Data by_dimension 135 bkk (Even): #{by_dimension_135_bkk_even}"
  #   puts "Data by_dimension 135 upc (Odd): #{by_dimension_135_upc_odd}"

  #   # Data of by_dimension 160 bkk
  #   by_dimension_160_bkk_even, by_dimension_160_upc_odd = middleware_plan_excel(sheet, 2, 23, 51)

  #   puts "Data by_dimension 160 bkk (Even): #{by_dimension_160_bkk_even}"
  #   puts "Data by_dimension 160 upc (Odd): #{by_dimension_160_upc_odd}"

  #   # Data of by_dimension 170 bkk
  #   by_dimension_170_bkk_even, by_dimension_170_upc_odd = middleware_plan_excel(sheet, 2, 23, 52)

  #   puts "Data by_dimension 170 bkk (Even): #{by_dimension_170_bkk_even}"
  #   puts "Data by_dimension 170 upc (Odd): #{by_dimension_170_upc_odd}"

  #   # Data of by_dimension 185 bkk
  #   by_dimension_185_bkk_even, by_dimension_185_upc_odd = middleware_plan_excel(sheet, 2, 23, 53)

  #   puts "Data by_dimension 185 bkk (Even): #{by_dimension_185_bkk_even}"
  #   puts "Data by_dimension 185 upc (Odd): #{by_dimension_185_upc_odd}"

  #   # Data of by_dimension 210 bkk
  #   by_dimension_210_bkk_even, by_dimension_210_upc_odd = middleware_plan_excel(sheet, 2, 23, 54)

  #   puts "Data by_dimension 210 bkk (Even): #{by_dimension_210_bkk_even}"
  #   puts "Data by_dimension 210 upc (Odd): #{by_dimension_210_upc_odd}"

  #   # Data of by_dimension 235 bkk
  #   by_dimension_235_bkk_even, by_dimension_235_upc_odd = middleware_plan_excel(sheet, 2, 23, 55)

  #   puts "Data by_dimension 235 bkk (Even): #{by_dimension_235_bkk_even}"
  #   puts "Data by_dimension 235 upc (Odd): #{by_dimension_235_upc_odd}"

  #   # Data of by_dimension 260 bkk
  #   by_dimension_260_bkk_even, by_dimension_260_upc_odd = middleware_plan_excel(sheet, 2, 23, 56)

  #   puts "Data by_dimension 260 bkk (Even): #{by_dimension_260_bkk_even}"
  #   puts "Data by_dimension 260 upc (Odd): #{by_dimension_260_upc_odd}"

  #   # Data of by_dimension 280 bkk
  #   by_dimension_280_bkk_even, by_dimension_280_upc_odd = middleware_plan_excel(sheet, 2, 23, 57)

  #   puts "Data by_dimension 280 bkk (Even): #{by_dimension_280_bkk_even}"
  #   puts "Data by_dimension 280 upc (Odd): #{by_dimension_280_upc_odd}"

  #   # Data of by_dimension others bkk
  #   by_dimension_others_bkk_even, by_dimension_others_upc_odd = middleware_plan_excel(sheet, 2, 23, 58)

  #   puts "Data by_dimension others bkk (Even): #{by_dimension_others_bkk_even}"
  #   puts "Data by_dimension others upc (Odd): #{by_dimension_others_upc_odd}"

  #   # Data of by_size C4 bkk
  #   by_size_C4_bkk_even, by_size_C4_upc_odd = middleware_plan_excel(sheet, 2, 3, 62)

  #   puts "Data by_size C4 bkk (Even): #{by_size_C4_bkk_even}"
  #   puts "Data by_size C4 upc (Odd): #{by_size_C4_upc_odd}"

  #   # Data of by_size A4 bkk
  #   by_size_A4_bkk_even, by_size_A4_upc_odd = middleware_plan_excel(sheet, 2, 3, 63)

  #   puts "Data by_size A4 bkk (Even): #{by_size_A4_bkk_even}"
  #   puts "Data by_size A4 upc (Odd): #{by_size_A4_upc_odd}"

  #   # Data of by_size A bkk
  #   by_size_A_bkk_even, by_size_A_upc_odd = middleware_plan_excel(sheet, 2, 3, 64)

  #   puts "Data by_size A bkk (Even): #{by_size_A_bkk_even}"
  #   puts "Data by_size A upc (Odd): #{by_size_A_upc_odd}"

  #   # Data of by_size B bkk
  #   by_size_B_bkk_even, by_size_B_upc_odd = middleware_plan_excel(sheet, 2, 3, 65)

  #   puts "Data by_size B bkk (Even): #{by_size_B_bkk_even}"
  #   puts "Data by_size B upc (Odd): #{by_size_B_upc_odd}"

  #   # Data of by_size B bkk
  #   by_size_C_bkk_even, by_size_C_upc_odd = middleware_plan_excel(sheet, 2, 3, 66)

  #   puts "Data by_size C bkk (Even): #{by_size_C_bkk_even}"
  #   puts "Data by_size C upc (Odd): #{by_size_C_upc_odd}"

  #   # Data of by_size D bkk
  #   by_size_D_bkk_even, by_size_D_upc_odd = middleware_plan_excel(sheet, 2, 3, 67)

  #   puts "Data by_size D bkk (Even): #{by_size_D_bkk_even}"
  #   puts "Data by_size D upc (Odd): #{by_size_D_upc_odd}"

  #   # Data of by_size E bkk
  #   by_size_E_bkk_even, by_size_E_upc_odd = middleware_plan_excel(sheet, 2, 3, 68)

  #   puts "Data by_size E bkk (Even): #{by_size_E_bkk_even}"
  #   puts "Data by_size E upc (Odd): #{by_size_E_upc_odd}"

  #   # Data of by_size F bkk
  #   by_size_F_bkk_even, by_size_F_upc_odd = middleware_plan_excel(sheet, 2, 3, 69)

  #   puts "Data by_size F bkk (Even): #{by_size_F_bkk_even}"
  #   puts "Data by_size F upc (Odd): #{by_size_F_upc_odd}"

  #   # Data of by_size others bkk
  #   by_size_others_bkk_even, by_size_others_upc_odd = middleware_plan_excel(sheet, 2, 3, 70)

  #   puts "Data by_size others bkk (Even): #{by_size_others_bkk_even}"
  #   puts "Data by_size others upc (Odd): #{by_size_others_upc_odd}"


  #   #Logic format data
  #   plan_form = {
  #     key_by_weight => {},
  #     key_by_dimesion => {},
  #     key_by_size => {}
  #   }

  #   transport_size = ["thaipost_one"]


  #   province.each do |prov|
  #     plan_form[key_by_weight][prov] = {}

  #     if prov == "bkk"
  #       weights.each_with_index do |weight, weight_index|
  #         plan_form[key_by_weight][prov][weight] = {}
  #         transport.each_with_index do |t, transport_index|
  #           case weight
  #           when 0
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_0_bkk[transport_index]
  #           when 20
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_20_bkk[transport_index]
  #           when 50
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_50_bkk[transport_index]
  #           when 100
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_100_bkk[transport_index]
  #           when 250
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_250_bkk[transport_index]
  #           when 500
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_500_bkk[transport_index]
  #           when 1000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_1000_bkk[transport_index]
  #           when 2000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_2000_bkk[transport_index]
  #           when 3000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_3000_bkk[transport_index]
  #           when 4000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_4000_bkk[transport_index]
  #           when 5000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_5000_bkk[transport_index]
  #           when 6000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_6000_bkk[transport_index]
  #           when 7000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_7000_bkk[transport_index]
  #           when 8000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_8000_bkk[transport_index]
  #           when 9000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_9000_bkk[transport_index]
  #           when 10000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_10000_bkk[transport_index]
  #           when 11000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_11000_bkk[transport_index]
  #           when 12000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_12000_bkk[transport_index]
  #           when 13000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_13000_bkk[transport_index]
  #           when 14000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_14000_bkk[transport_index]
  #           when 15000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_15000_bkk[transport_index]
  #           when 16000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_16000_bkk[transport_index]
  #           when 17000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_17000_bkk[transport_index]
  #           when 18000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_18000_bkk[transport_index]
  #           when 19000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_19000_bkk[transport_index]
  #           when 20000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_20000_bkk[transport_index]
  #           when "others"
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_others_bkk[transport_index]
  #           end


  #         end
  #       end

  #     elsif prov == "upc"
  #       weights.each_with_index do |weight, weight_index|
  #         plan_form[key_by_weight][prov][weight] = {}
  #         transport.each_with_index do |t, transport_index|
  #           case weight
  #           when 0
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_0_upc[transport_index]
  #           when 20
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_20_upc[transport_index]
  #           when 50
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_50_upc[transport_index]
  #           when 100
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_100_upc[transport_index]
  #           when 250
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_250_upc[transport_index]
  #           when 500
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_500_upc[transport_index]
  #           when 1000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_1000_upc[transport_index]
  #           when 2000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_2000_upc[transport_index]
  #           when 3000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_3000_upc[transport_index]
  #           when 4000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_4000_upc[transport_index]
  #           when 5000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_5000_upc[transport_index]
  #           when 6000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_6000_upc[transport_index]
  #           when 7000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_7000_upc[transport_index]
  #           when 8000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_8000_upc[transport_index]
  #           when 9000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_9000_upc[transport_index]
  #           when 10000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_10000_upc[transport_index]
  #           when 11000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_11000_upc[transport_index]
  #           when 12000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_12000_upc[transport_index]
  #           when 13000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_13000_upc[transport_index]
  #           when 14000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_14000_upc[transport_index]
  #           when 15000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_15000_upc[transport_index]
  #           when 16000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_16000_upc[transport_index]
  #           when 17000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_17000_upc[transport_index]
  #           when 18000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_18000_upc[transport_index]
  #           when 19000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_19000_upc[transport_index]
  #           when 20000
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_20000_upc[transport_index]
  #           when "others"
  #             plan_form[key_by_weight][prov][weight][t] = by_weight_others_upc[transport_index]
  #           end


  #         end
  #       end
  #     end
  #   end

  #   province.each do |prov|
  #     plan_form[key_by_dimesion][prov] = {}

  #     if prov == "bkk"
  #       weights_by_dimension.each_with_index do |weight, weight_index|
  #         plan_form[key_by_dimesion][prov][weight] = {}
  #         transport.each_with_index do |t, transport_index|
  #           case weight
  #           when 20
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_20_bkk_even[transport_index]
  #           when 35
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_35_bkk_even[transport_index]
  #           when 40
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_40_bkk_even[transport_index]
  #           when 45
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_45_bkk_even[transport_index]
  #           when 55
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_55_bkk_even[transport_index]
  #           when 65
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_65_bkk_even[transport_index]
  #           when 75
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_75_bkk_even[transport_index]
  #           when 85
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_85_bkk_even[transport_index]
  #           when 90
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_90_bkk_even[transport_index]
  #           when 95
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_95_bkk_even[transport_index]
  #           when 100
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_100_bkk_even[transport_index]
  #           when 105
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_105_bkk_even[transport_index]
  #           when 110
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_110_bkk_even[transport_index]
  #           when 115
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_115_bkk_even[transport_index]
  #           when 120
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_120_bkk_even[transport_index]
  #           when 125
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_125_bkk_even[transport_index]
  #           when 130
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_130_bkk_even[transport_index]
  #           when 135
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_135_bkk_even[transport_index]
  #           when 160
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_160_bkk_even[transport_index]
  #           when 170
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_170_bkk_even[transport_index]
  #           when 185
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_185_bkk_even[transport_index]
  #           when 210
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_210_bkk_even[transport_index]
  #           when 235
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_235_bkk_even[transport_index]
  #           when 260
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_260_bkk_even[transport_index]
  #           when 280
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_280_bkk_even[transport_index]
  #           when "others"
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_others_bkk_even[transport_index]
  #           end


  #         end
  #       end

  #     elsif prov == "upc"
  #       weights_by_dimension.each_with_index do |weight, weight_index|
  #         plan_form[key_by_dimesion][prov][weight] = {}
  #         transport.each_with_index do |t, transport_index|
  #           case weight
  #           when 20
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_20_upc_odd[transport_index]
  #           when 35
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_35_upc_odd[transport_index]
  #           when 40
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_40_upc_odd[transport_index]
  #           when 45
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_45_upc_odd[transport_index]
  #           when 55
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_55_upc_odd[transport_index]
  #           when 65
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_65_upc_odd[transport_index]
  #           when 75
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_75_upc_odd[transport_index]
  #           when 85
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_85_upc_odd[transport_index]
  #           when 90
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_90_upc_odd[transport_index]
  #           when 95
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_95_upc_odd[transport_index]
  #           when 100
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_100_upc_odd[transport_index]
  #           when 105
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_105_upc_odd[transport_index]
  #           when 110
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_110_upc_odd[transport_index]
  #           when 115
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_115_upc_odd[transport_index]
  #           when 120
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_120_upc_odd[transport_index]
  #           when 125
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_125_upc_odd[transport_index]
  #           when 130
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_130_upc_odd[transport_index]
  #           when 135
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_135_upc_odd[transport_index]
  #           when 160
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_160_upc_odd[transport_index]
  #           when 170
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_170_upc_odd[transport_index]
  #           when 185
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_185_upc_odd[transport_index]
  #           when 210
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_210_upc_odd[transport_index]
  #           when 235
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_235_upc_odd[transport_index]
  #           when 260
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_260_upc_odd[transport_index]
  #           when 280
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_280_upc_odd[transport_index]
  #           when "others"
  #             plan_form[key_by_dimesion][prov][weight][t] = by_dimension_others_upc_odd[transport_index]
  #           end


  #         end
  #       end
  #     end
  #   end

  #   province.each do |prov|
  #     plan_form[key_by_size][prov] = {}

  #     if prov == "bkk"
  #       weights_by_size.each_with_index do |weight, weight_index|
  #         plan_form[key_by_size][prov][weight] = {}
  #         transport_size.each_with_index do |t, transport_index|
  #           case weight
  #           when "C4"
  #             plan_form[key_by_size][prov][weight][t] = by_size_C4_bkk_even[transport_index]
  #           when "A4"
  #             plan_form[key_by_size][prov][weight][t] = by_size_A4_bkk_even[transport_index]
  #           when "A"
  #             plan_form[key_by_size][prov][weight][t] = by_size_A_bkk_even[transport_index]
  #           when "B"
  #             plan_form[key_by_size][prov][weight][t] = by_size_B_bkk_even[transport_index]
  #           when "C"
  #             plan_form[key_by_size][prov][weight][t] = by_size_C_bkk_even[transport_index]
  #           when "D"
  #             plan_form[key_by_size][prov][weight][t] = by_size_D_bkk_even[transport_index]
  #           when "E"
  #             plan_form[key_by_size][prov][weight][t] = by_size_E_bkk_even[transport_index]
  #           when "F"
  #             plan_form[key_by_size][prov][weight][t] = by_size_F_bkk_even[transport_index]
  #           when "others"
  #             plan_form[key_by_size][prov][weight][t] = by_size_others_bkk_even[transport_index]
  #           end


  #         end
  #       end

  #     elsif prov == "upc"
  #       weights_by_size.each_with_index do |weight, weight_index|
  #         plan_form[key_by_size][prov][weight] = {}
  #         transport_size.each_with_index do |t, transport_index|
  #           case weight
  #           when "C4"
  #             plan_form[key_by_size][prov][weight][t] = by_size_C4_upc_odd[transport_index]
  #           when "A4"
  #             plan_form[key_by_size][prov][weight][t] = by_size_A4_upc_odd[transport_index]
  #           when "A"
  #             plan_form[key_by_size][prov][weight][t] = by_size_A_upc_odd[transport_index]
  #           when "B"
  #             plan_form[key_by_size][prov][weight][t] = by_size_B_upc_odd[transport_index]
  #           when "C"
  #             plan_form[key_by_size][prov][weight][t] = by_size_C_upc_odd[transport_index]
  #           when "D"
  #             plan_form[key_by_size][prov][weight][t] = by_size_D_upc_odd[transport_index]
  #           when "E"
  #             plan_form[key_by_size][prov][weight][t] = by_size_E_upc_odd[transport_index]
  #           when "F"
  #             plan_form[key_by_size][prov][weight][t] = by_size_F_upc_odd[transport_index]
  #           when "others"
  #             plan_form[key_by_size][prov][weight][t] = by_size_others_upc_odd[transport_index]
  #           end


  #         end
  #       end
  #     end
  #   end

  #   puts "format: #{JSON.pretty_generate(plan_form)}"

  # end


  def middleware_plan_excel(sheet, start_column, end_column, row_number)
    # Retrieve the values in the specified range for even-numbered columns
    even_values = (start_column..end_column).select(&:even?).map { |column| sheet.cell(row_number, column) }

    # Retrieve the values in the specified range for odd-numbered columns
    odd_values = (start_column..end_column).select(&:odd?).map { |column| sheet.cell(row_number, column) }

    return even_values, odd_values
  end

end
