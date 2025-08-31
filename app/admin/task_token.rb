ActiveAdmin.register TaskToken do
  menu priority: 100, label: "Task Token"

  actions :index
  filter :token_name

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, TaskToken
    end
  end

  filter :token_name
  filter :token_id

  permit_params :token_name, :token_id

  index do
    column :token_name
    column :token_id
    column :description
    column :cn_description
    column :created_at
    column :updated_at
  end
end
