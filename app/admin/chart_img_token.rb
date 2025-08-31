ActiveAdmin.register ChartImgToken do
  menu priority: 100, label: "Chart Img Token"

  actions :index
  filter :symbol
  filter :network

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, ChartImgToken
    end
  end

  permit_params :symbol, :network, :description

  index do
    selectable_column
    column :symbol
    column :network
    column :description
  end
end
