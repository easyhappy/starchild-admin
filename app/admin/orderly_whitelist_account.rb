ActiveAdmin.register OrderlyWhitelistAccount do
  menu priority: 100, label: "Orderly Whitelist Account"

  actions :index, :new, :create, :edit, :update, :show
  filter :account

  controller do
    before_action :check_permissions

    def check_permissions
      authorize! :manage, OrderlyWhitelistAccount
    end
  end

  filter :account
  filter :telegram_user_id

  permit_params :account, :volume

  form do |f|
    f.inputs "Whitelist Account Details" do
      f.input :account
      f.input :volume
    end
    f.actions
  end

  index do
    selectable_column
    column :account
    column :volume
    actions
  end
end
