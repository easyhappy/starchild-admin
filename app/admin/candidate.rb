ActiveAdmin.register Candidate   do
  menu priority: 100, label: "Candidate"

  actions :index
  filter :account

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, Candidate
    end
  end

  index do
    column :id
    column :account
    column :user_agent
    column :ip
    column :created_at
    column :updated_at
  end
end
