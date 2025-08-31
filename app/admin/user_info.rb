ActiveAdmin.register UserInfo do
  menu priority: 100, label: "User Info"

  actions :index
  filter :userid

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, UserInfo
    end
  end

  filter :userid

  permit_params :userid, :user_name

  index do
    selectable_column
    column :userid
    column :user_name
    column :avatar_url
    column :settings
  end
end
