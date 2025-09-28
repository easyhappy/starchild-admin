ActiveAdmin.register DefaultWebsearchWord do
  menu priority: 100, label: "Default Websearch Word"

  actions :index, :new, :create, :edit, :update, :show
  filter :word

  controller do
    before_action :check_permissions

    def check_permissions
      authorize! :manage, DefaultWebsearchWord
    end
  end

  permit_params :word

  form do |f|
    f.inputs "Default Websearch Word Details" do
      f.input :word
    end
    f.actions
  end

  index do
    selectable_column
    column :word
    actions
  end
end
