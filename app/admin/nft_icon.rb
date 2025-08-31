ActiveAdmin.register NftIcon    do
  menu priority: 100, label: "Nft Icon"

  actions :index, :new, :create, :edit, :update, :show
  filter :icon_url
  filter :nft_id


  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, NftIcon
    end
  end

  filter :icon_url
  filter :nft_id

  permit_params :icon_url, :nft_id

  form do |f|
    f.inputs "Nft Icon Details" do
      f.input :icon_url, as: :string
      f.input :nft_id, as: :string
    end
    f.actions
  end

  index do
    selectable_column
    column :icon_url
    column :nft_id
    column :created_at
    column :updated_at
    actions
  end
end
