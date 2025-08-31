ActiveAdmin.register SubscriptionTask do
  menu priority: 100, label: "Subscription Task"

  actions :index
  filter :user_id

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, SubscriptionTask
    end
  end

  filter :user_id

  permit_params :user_id

  index do
    column :id
    column :user_id
    column :task_id
    column :created_at
    column :updated_at
  end
end
