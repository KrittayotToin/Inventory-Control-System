# equipment seeds
Equipment.create!(
    equipment_code: 'EQ-001',
    equipment_type: 'Laptop',
    equipment_name: 'Macbook Pro',
    equipment_serial_number: 'C02T98JFH8WM',
    equipment_amount: 5,
    equipment_status: 'available'
  )
  
  Equipment.create!(
    equipment_code: 'EQ-002',
    equipment_type: 'Monitor',
    equipment_name: 'LG Ultrawide',
    equipment_serial_number: 'FLA5699CD1',
    equipment_amount: 10,
    equipment_status: 'available'
  )
  
  # member seeds
  Member.create!(
    member_code: 'MEM-001',
    member_name: 'John Doe',
    member_phone: '+1 555-1234',
    member_email: 'john.doe@example.com',
    member_department: 'IT'
  )
  
  Member.create!(
    member_code: 'MEM-002',
    member_name: 'Jane Smith',
    member_phone: '+1 555-5678',
    member_email: 'jane.smith@example.com',
    member_department: 'HR'
  )
  
  # log control seeds
  LogControl.create!(
    equipment_id: 1,
    member_id: 1,
    log_status: 'Borrowed',
    log_date: Date.today
  )
  
  LogControl.create!(
    equipment_id: 2,
    member_id: 2,
    log_status: 'Returned',
    log_date: Date.yesterday
  )
  