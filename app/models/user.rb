class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

         enum role: { user: 0, admin: 1 }

  def admin?
    role == "admin"
  end


  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  
  # def self.from_omniauth(auth)
  #   name_split = auth.info.name.split(" ")
  #   user = User.where(email: auth.info.email).first
  #   user ||= User.create!(provider: auth.provider, uid: auth.uid, last_name: name_split[0], first_name: name_split[1], email: auth.info.email, password: Devise.friendly_token[0, 20])
  #     user
  # end

  def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.email = auth.info.email
			user.password = Devise.friendly_token[0,20]
			user.name = auth.info.name   # assuming the user model has a name
			user.image = auth.info.image # assuming the user model has an image
		end
	end
end

#database_authenticatable: ผู้ใช้สามารถยืนยันตัวตนด้วยฟิลด์ล็อกอินและรหัสผ่าน รหัสผ่านที่เข้ารหัสจะถูกจัดเก็บไว้ในฐานข้อมูลของคุณ
#registerable: ผู้ใช้สามารถลงทะเบียนด้วยตนเองและสามารถแก้ไขหรือลบบัญชีของตนได้
#recoverable: ผู้ใช้สามารถรีเซ็ตรหัสผ่านและกู้คืนบัญชีได้หากลืมข้อมูลประจำตัว
#rememberable: โมดูลนี้จดจำเซสชันของผู้ใช้โดยบันทึกข้อมูลในคุกกี้ของเบราว์เซอร์
#validatable: โมดูลนี้มีการตรวจสอบความถูกต้องสำหรับฟิลด์อีเมลและรหัสผ่านของผู้ใช้ (ตัวอย่างเช่น แอปพลิเคชันของคุณขอรหัสผ่านอย่างน้อยหกอักขระ แม้ว่าคุณจะไม่ได้กำหนดการตรวจสอบความถูกต้องที่กำหนดเองในโมเดลของคุณก็ตาม)