ActiveAdmin.register DefaultWebSearchWord do
  menu priority: 100, label: "Default WebSearch Word"

  actions :index, :new, :create, :edit, :update, :show
  filter :word

  controller do
    before_action :check_permissions

    def check_permissions
      authorize! :manage, DefaultWebSearchWord
    end
  end

  permit_params :word

  form do |f|
    f.inputs "Default WebSearch Word Details" do
      f.input :word, as: :string
    end
    f.actions
  end

  index do
    selectable_column
    column :word
    actions
  end
end
