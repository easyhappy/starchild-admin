ActiveAdmin.register Kol do
  menu priority: 5, label: "KOL"

  actions :index, :show, :new, :create, :edit, :update, :destroy

  permit_params :kol_name, :kol_avatar, :weight, :kol_id, :description, :cn_description

  controller do
    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, Kol
    end
  end

  config.sort_order = 'weight_desc'

  index do
    selectable_column
    id_column
    column :kol_name
    column :kol_avatar do |kol|
      if kol.kol_avatar.present?
        image_tag kol.kol_avatar, size: "50x50", style: "border-radius: 50%;"
      else
        "No Avatar"
      end
    end
    column :weight
    column :kol_id
    column :description
    column :cn_description
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :kol_name
      row :kol_avatar do |kol|
        if kol.kol_avatar.present?
          image_tag kol.kol_avatar, size: "100x100", style: "border-radius: 50%;"
        else
          "No Avatar"
        end
      end
      row :weight
      row :kol_id
      row :description
      row :cn_description
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "KOL Details" do
      f.input :kol_name, required: true, hint: "Enter KOL name", as: :string
      f.input :kol_avatar, hint: "Enter avatar URL", as: :string
      f.input :weight, hint: "Enter weight", as: :number
      f.input :kol_id, hint: "Enter KOL ID", as: :string
      f.input :description, hint: "Enter English description", as: :string
      f.input :cn_description, hint: "Enter Chinese description", as: :string
    end
    f.actions
  end

  filter :kol_name
  filter :created_at
  filter :updated_at
end
