ActiveAdmin.register WhitelistAccount    do
  menu priority: 100, label: "Whitelist Account"

  actions :index, :new, :create, :edit, :update, :show
  filter :account


  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, WhitelistAccount
    end
  end

  filter :account
  filter :telegram_user_id

  permit_params :account, :burn_at, :mint_tx_status, :mint_tx_hash, :telegram_user_id, :nft_id, :valid_at, :is_vip 

  form do |f|
    f.inputs "Whitelist Account Details" do
      f.input :account
      f.input :burn_at, as: :string
      f.input :mint_tx_status, as: :string
      f.input :mint_tx_hash, as: :string
      f.input :telegram_user_id, as: :string
      f.input :nft_id, as: :string
      f.input :valid_at
      f.input :is_vip
    end
    f.actions
  end

  index do
    selectable_column
    column :account
    column :burn_at
    column :mint_tx_status
    column :mint_tx_hash
    column :telegram_user_id
    column :burn_tx_hash
    column :burn_status
    column :nft_id
    column :created_at
    column :updated_at
    column :valid_at
    column :is_vip
    actions
  end
end
