class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable
  
  # 添加角色字段，可以是 admin, editor 等
  validates :role, presence: true, inclusion: { in: %w(admin editor) }
  
  # 添加自定义方法检查是否为超级管理员
  def super_admin?
    role == 'admin'
  end
  
  # 允许用户更新密码
  def update_with_password(params)
    current_password = params.delete(:current_password)
    
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    
    result = if valid_password?(current_password)
      update(params)
    else
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end
    
    clean_up_passwords
    result
  end
  
  # 确保 to_s 方法返回有意义的字符串
  def to_s
    email.to_s
  end
end 