module Admin
  class PasswordsController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'active_admin'
    
    def edit
      @admin_user = current_admin_user
    end
    
    def update
      @admin_user = current_admin_user
      
      if params[:admin_user][:password].blank?
        @admin_user.errors.add(:password, "不能为空")
        render :edit
        return
      end
      
      if params[:admin_user][:password] != params[:admin_user][:password_confirmation]
        @admin_user.errors.add(:password_confirmation, "与密码不匹配")
        render :edit
        return
      end
      
      if @admin_user.update_with_password(admin_user_params)
        # 更新成功后重新登录
        sign_in @admin_user, bypass: true
        redirect_to root_path, notice: "密码已成功更新"
      else
        render :edit
      end
    end
    
    private
    
    def admin_user_params
      params.require(:admin_user).permit(:current_password, :password, :password_confirmation)
    end
  end
end 