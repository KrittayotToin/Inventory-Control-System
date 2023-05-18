class Member < ApplicationRecord
    validates :member_code, presence: true, uniqueness: true
    validates :member_name, presence: true
    validates :member_phone, presence: true, length: { is: 10 }
  
    before_validation :generate_member_code, on: :create
    
    has_many :log_controls
    has_many :equipment, through: :log_controls

    
    private
  
    def generate_member_code
      self.member_code = "skybox_#{sprintf('%03d', Member.count + 1)}"# set the member_code to skybox_{count+1}"
    end
  end


  