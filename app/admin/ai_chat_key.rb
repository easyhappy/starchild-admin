ActiveAdmin.register AiChatKey do
  menu priority: 100, label: "AI Chat Key"

  actions :index

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, AiChatKey
    end
  end

  filter :account

  permit_params :user_id

  index do
    column :id
    column :account
    column :ai_api_key
  end
end
