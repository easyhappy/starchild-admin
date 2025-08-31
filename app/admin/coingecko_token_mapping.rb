ActiveAdmin.register CoingeckoTokenMapping   do
  menu priority: 5, label: "Coingecko Token Mapping"

  actions :index

  filter :token
  filter :token_alias

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, CoingeckoTokenMapping
    end
  end

  index do
    selectable_column
    column :token
    column :token_alias
  end

end