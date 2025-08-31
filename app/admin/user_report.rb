ActiveAdmin.register UserReport do
  menu priority: 100, label: "User Report"

  actions :index
  filter :user_id

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, UserReport
    end
  end

  filter :user_id

  config.sort_order = 'creat_at_desc'

  permit_params :user_id

  index do
    selectable_column
    column :report_id
    column :user_id
    column :user_name
    column :content
    column :created_at
    column :msg_id
    column :extra
  end
end
