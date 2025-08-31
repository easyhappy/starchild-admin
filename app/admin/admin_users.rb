ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, :role

  # 添加自定义操作

  # 只定义一个 index 块
  index do
    selectable_column
    id_column
    column :email
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    
    # 自定义操作列
    column "操作" do |admin_user|
      links = ''.html_safe
      links += link_to "查看", resource_path(admin_user), class: "member_link"
      if current_admin_user.super_admin?
        links += link_to "编辑", edit_resource_path(admin_user), class: "member_link"
        if admin_user.id != current_admin_user.id
          links += link_to "删除", resource_path(admin_user), method: :delete, data: { confirm: "确定要删除吗?" }, class: "member_link"
        end
      elsif admin_user.id == current_admin_user.id
        links += link_to "编辑", edit_resource_path(admin_user), class: "member_link"
      end
      links
    end
  end

  filter :email
  filter :role
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  # 根据当前用户角色和编辑对象提供不同的表单
  form do |f|
    f.inputs do
      # 如果是超级管理员或者是编辑自己的账户
      if current_admin_user.super_admin?
        # 超级管理员可以编辑所有字段
        f.input :email
        f.input :password
        f.input :password_confirmation
        f.input :role, as: :select, collection: %w(admin editor)
      else
        # 非超级管理员只能修改自己的密码
        f.input :password
        f.input :password_confirmation
      end
    end
    
    # 为非管理员添加只读信息
    unless current_admin_user.super_admin?
      f.inputs "只读信息" do
        li do
          label "Email"
          text_node f.object.email.to_s
        end
        
        li do
          label "Role"
          text_node f.object.role.to_s
        end
      end
    end
    
    f.actions
  end
  
  # 只有超级管理员可以管理其他管理员
  controller do
    # 修改为不需要参数的方法
    before_action :check_admin_permissions, only: [:new, :create, :destroy]
    
    def check_admin_permissions
      authorize! :manage, AdminUser
    end
    
    # 防止管理员删除自己的账户
    before_action only: [:destroy] do
      if resource.id == current_admin_user.id
        flash[:error] = "不能删除自己的账户"
        redirect_to admin_admin_users_path
      end
    end
    
    # 重写 update 方法，限制非管理员只能更新密码
    def update
      if current_admin_user.super_admin? || params[:id].to_i == current_admin_user.id
        # 如果不是超级管理员，只允许更新密码
        unless current_admin_user.super_admin?
          params[:admin_user].delete(:email)
          params[:admin_user].delete(:role)
        end
        
        super
      else
        flash[:error] = "没有权限执行此操作"
        redirect_to admin_admin_users_path
      end
    end
    
    # 确保资源正确加载
    def find_resource
      @admin_user = AdminUser.find(params[:id])
    end
  end

  # 自定义显示页面，添加修改密码按钮
  show do
    attributes_table do
      row :id
      row :email
      row :role
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
    end
    
    # 如果是当前用户，显示修改密码按钮
  end
end 